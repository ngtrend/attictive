extends Node

const TITLE_ID = "CA909"
const PLAYFAB_API = "https://%s.playfabapi.com" % TITLE_ID

var session_ticket := ""
var playfab_id := ""
var display_name = ""

var leaderboard_data: Array = []
var pending_score := 0
var last_submitted_score := 0

signal leaderboard_updated
signal  login_completed(has_display_name : bool)

var refresh_timer : Timer
var score_submit_timer : Timer

# Request tracking flags
var is_fetching_leaderboard := false
var is_fetching_player_rank := false
var is_submitting_score := false

func _ready():
	login_anonymous()
	setup_auto_timer()
	setup_score_timer()
func setup_auto_timer():
	refresh_timer = Timer.new()
	refresh_timer.wait_time = 5.0
	refresh_timer.timeout.connect(_on_restart_timer_timeout)
	add_child(refresh_timer)
func setup_score_timer():
	score_submit_timer = Timer.new()
	score_submit_timer.wait_time = 5.0
	score_submit_timer.timeout.connect(_on_score_submit_timer_timeout)
	add_child(score_submit_timer)
func start_auto_refresh():
	if session_ticket != "":
		refresh_timer.start()
		score_submit_timer.start()
func stop_auto_refresh():
	refresh_timer.stop()
func _on_restart_timer_timeout():
	if !is_fetching_leaderboard:
		fetch_leaderboard(3)
func _on_score_submit_timer_timeout():
	if !is_submitting_score and pending_score >= 0 and pending_score != last_submitted_score:
		submit_score_now(pending_score)
func login_anonymous():
	var custom_id := OS.get_unique_id()
	if custom_id == "":
		custom_id = str(Time.get_unix_time_from_system())

	var payload = {
		"TitleId": TITLE_ID,
		"CustomId": custom_id,
		"CreateAccount": true,
		"InfoRequestParameters": {
			"GetPlayerProfile": true
		}
	}

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity"
	]

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(result, response_code, _response_headers, body):
			_on_login_response(result, response_code, _response_headers, body, http)
	)

	var err = http.request(
		PLAYFAB_API + "/Client/LoginWithCustomID",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		push_error("HTTPRequest failed to start: " + str(err))

func _on_login_response(_result, response_code, _headers, body, http: HTTPRequest):
	var text = body.get_string_from_utf8()

	if response_code != 200:
		push_error("PlayFab login failed (" + str(response_code) + "): " + text)
		return

	var response = JSON.parse_string(text)

	session_ticket = response["data"]["SessionTicket"]
	playfab_id = response["data"]["PlayFabId"]
	 # Check if player has a DisplayName
	var profile = response["data"].get("InfoResultPayload", {}).get("PlayerProfile", {})
	display_name = profile.get("DisplayName", "")
	print("✅ PlayFab login success")
	print("PlayFabId:", playfab_id)
	print("Display name: ", display_name)
	emit_signal("login_completed", display_name != "")
	fetch_leaderboard(3)
	start_auto_refresh()
	http.queue_free()
func set_display_name(_name: String) -> void:
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet")
		return

	var payload = {
		"DisplayName": _name
	}

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity",
		"X-Authorization: %s" % session_ticket
	]

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(result, response_code, _response_headers, body):
			_on_set_name_response(result, response_code, _response_headers, body, http, _name)
	)

	var err = http.request(
		PLAYFAB_API + "/Client/UpdateUserTitleDisplayName",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		push_error("Set display name failed to start: " + str(err))
func _on_set_name_response(_result, response_code, _headers, body, http, _name: String):
	if response_code != 200:
		push_error("Set display name failed: " + body.get_string_from_utf8())
		http.queue_free()
		return
	
	display_name = _name
	print("✅ Display name set to:", _name)
	http.queue_free()
func submit_score(score : int) -> void:
	pending_score = score
func submit_score_now(score: int) -> void:
	# safety: don’t send if not logged in yet
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet, score skipped")
		return
	if is_submitting_score:
		print("Score submit already in progress")
		return
	is_submitting_score = true

	var payload = {
		"Statistics": [
			{
				"StatisticName": "HighScore",
				"Value": score
			}
		]
	}

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity",
		"X-Authorization: %s" % session_ticket
	]

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(result, response_code, _response_headers, body):
			_on_submit_score_response(result, response_code, _response_headers, body, http)
	)

	var err = http.request(
		PLAYFAB_API + "/Client/UpdatePlayerStatistics",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		push_error("Score submit failed to start: " + str(err))
		is_submitting_score = false
func _on_submit_score_response(_result, response_code, _headers, body, http):
	if response_code != 200:
		push_error("Score submit failed (%d): %s" % [
			response_code,
			body.get_string_from_utf8()
		])
		http.queue_free()
		is_submitting_score = false
		return
	last_submitted_score = pending_score
	is_submitting_score = false
	print("Score submitted")
	update_local_player_score(last_submitted_score)
	http.queue_free()
func update_local_player_score(new_score : int) -> void :
	for i in range(leaderboard_data.size()):
		if leaderboard_data[i]["id"] == playfab_id:
			leaderboard_data[i]["score"] = new_score
			break
	leaderboard_data.sort_custom(func(a,b):return a["score"] > b["score"])
	for j in range(leaderboard_data.size()):
		leaderboard_data[j]["rank"] = j + 1
	emit_signal("leaderboard_updated")
	print("Local optimistically updated")
func fetch_leaderboard(max_results := 4):
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet")
		return
	if is_fetching_leaderboard:
		print("Leaderboard fetch already in process")
		return
	is_fetching_leaderboard = true

	var payload = {
		"StatisticName": "HighScore",
		"StartPosition": 0,
		"MaxResultsCount": max_results
	}

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity",
		"X-Authorization: %s" % session_ticket
	]

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(result, response_code, _response_headers, body):
			_on_leaderboard_response(result, response_code, _response_headers, body, http)
	)

	var err = http.request(
		PLAYFAB_API + "/Client/GetLeaderboard",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		push_error("Leaderboard request failed to start: " + str(err))
		is_fetching_leaderboard = false
func _on_leaderboard_response(_result, response_code, _headers, body, http):
	if response_code != 200:
		push_error("Leaderboard fetch failed: " + body.get_string_from_utf8())
		http.queue_free()
		is_fetching_leaderboard = false
		return
	is_fetching_leaderboard = false
	var data = JSON.parse_string(body.get_string_from_utf8())
	var list = data["data"]["Leaderboard"]
	leaderboard_data.clear()
	for entry in list:
		leaderboard_data.append({
			"rank": int(entry["Position"] + 1),
			"score": int(entry["StatValue"]),
			"name": entry.get("DisplayName", "Player"),
			"id": entry["PlayFabId"]
		})
	if !is_player_in_top_3():
		fetch_player_rank()
	else:
		emit_signal("leaderboard_updated")
	http.queue_free()
func fetch_player_rank():
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet")
		return
	if is_fetching_player_rank:
		print("Player rank fetch already in progress, skipping")
		return
	is_fetching_player_rank = true
	var payload = {
		"StatisticName": "HighScore",
		"MaxResultsCount": 1,  # Just get the player's own entry
		"ProfileConstraints": {
			"ShowDisplayName": true
		}
	}

	var headers = [
		"Content-Type: application/json",
		"Accept-Encoding: identity",
		"X-Authorization: %s" % session_ticket
	]
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(
		func(result, response_code, _response_headers, body):
			_on_player_rank_response(result, response_code, _response_headers, body, http)
	)

	var err = http.request(
		PLAYFAB_API + "/Client/GetLeaderboardAroundPlayer",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if err != OK:
		push_error("Player rank request failed to start: " + str(err))
		is_fetching_player_rank = false
func _on_player_rank_response(_result, response_code, _headers, body, http):
	if response_code != 200:
		push_error("Player rank fetch failed: " + body.get_string_from_utf8())
		http.queue_free()
		is_fetching_player_rank = false
		return
	
	is_fetching_player_rank = false
	var data = JSON.parse_string(body.get_string_from_utf8())
	var list = data["data"]["Leaderboard"]
	
	if list.size() > 0:
		var entry = list[0]
		var player_data = {
			"rank": int(entry["Position"] + 1),
			"score": int(entry["StatValue"]),
			"name": entry.get("DisplayName", display_name),
			"id": entry["PlayFabId"]
		}
		
		# Store separately or add to leaderboard_data
		leaderboard_data.append(player_data)
		emit_signal("leaderboard_updated")
	
	http.queue_free()

func is_player_in_top_3() -> bool :
	for entry in leaderboard_data:
		if entry["id"] == playfab_id:
			return true
	return false
