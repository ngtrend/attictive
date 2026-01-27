extends Node

const TITLE_ID = "CA909"
const PLAYFAB_API = "https://%s.playfabapi.com" % TITLE_ID

var session_ticket := ""
var playfab_id := ""

var leaderboard_data: Array = []
signal leadderboard_updated

func _ready():
	login_anonymous()

func login_anonymous():
	var custom_id := OS.get_unique_id()
	if custom_id == "":
		custom_id = str(Time.get_unix_time_from_system())

	var payload = {
		"TitleId": TITLE_ID,
		"CustomId": custom_id,
		"CreateAccount": true
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

	print("✅ PlayFab login success")
	print("PlayFabId:", playfab_id)
	http.queue_free()
func submit_score(score: int) -> void:
	# safety: don’t send if not logged in yet
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet, score skipped")
		return

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
func _on_submit_score_response(_result, response_code, _headers, body, http):
	if response_code != 200:
		push_error("Score submit failed (%d): %s" % [
			response_code,
			body.get_string_from_utf8()
		])
		http.queue_free()
		return
	await get_tree().create_timer(0.2).timeout
	fetch_leaderboard(10)
	http.queue_free()
func fetch_leaderboard(max_results := 10):
	if session_ticket == "":
		print("⚠ PlayFab not logged in yet")
		return

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
func _on_leaderboard_response(_result, response_code, _headers, body, http):
	if response_code != 200:
		push_error("Leaderboard fetch failed: " + body.get_string_from_utf8())
		http.queue_free()
		return

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

	emit_signal("leadderboard_updated")
	http.queue_free()
