import os
from oauthlib.oauth2 import BackendApplicationClient
from requests_oauthlib import OAuth2Session
import requests
import json
from datetime import datetime, timedelta
import calendar
from termcolor import colored

client_id = os.environ.get("LOGTIME_CLIENT_ID")
client_secret = os.environ.get("LOGTIME_CLIENT_SECRET")

if not client_id or not client_secret:
	print("Please set the LOGTIME_CLIENT_ID and LOGTIME_CLIENT_SECRET environment variables.")

client = BackendApplicationClient(client_id)
oauth = OAuth2Session(client=client, scope='public')
token_url = 'https://api.intra.42.fr/oauth/token'

token = oauth.fetch_token(
    token_url=token_url,
    client_secret=client_secret,
)
if not token:
	print("An error occured when trying to fetch token. Incorrect client-id or client-secret ?")
	exit()

access_token = token['access_token']
if not access_token:
	print("Unable to get access token.")
	exit()

user_id = os.environ.get('USER')
api_base_url = 'https://api.intra.42.fr/v2/'
api_url = f'{api_base_url}/locations'

# Set the authorization header with the access token	
headers = {
    'Authorization': f'Bearer {access_token}'
}

curr_user = os.getenv('USER')

params={
	'user_id': curr_user
}

response = requests.get(api_url, headers=headers, params=params)

if not response.status_code >= 200 and not response.status_code < 300:
    print(f"Request failed with status code: {response.status_code}")
    exit()

begin_at = response.json()
current_date = datetime.now().date()
date_time_objects = []

curr_time = str(datetime.now())
curr_time = datetime.strptime(curr_time, "%Y-%m-%d %H:%M:%S.%f")
for item in begin_at:
	begin_at_time = datetime.strptime(item['begin_at'],  "%Y-%m-%dT%H:%M:%S.%fZ")
	if (item['end_at'] is not None):
		end_at_time = datetime.strptime(item['end_at'], "%Y-%m-%dT%H:%M:%S.%fZ")
	else:
		end_at_time = curr_time

	if (begin_at_time.date() == current_date):
		date_time_objects.append((begin_at_time, end_at_time))

total_time_diff = 0

for begin_datetime, end_datetime in date_time_objects:
    time_difference = end_datetime - begin_datetime
    total_time_diff += time_difference.total_seconds()

api_url = f'{api_base_url}/users/{curr_user}/locations_stats'
response = requests.get(api_url, headers=headers, params=params)

data = response.json()
if not response.status_code >= 200 and not response.status_code < 300:
    print(f"Request failed with status code: {response.status_code}")
    exit()

data = response.json()
month_sums = {}

for date, time in data.items():
	month = date.split('-')[1]
	month_name = calendar.month_name[int(month)]
	time_obj = datetime.strptime(time, '%H:%M:%S.%f')
	log_time_in_seconds = time_obj - time_obj.replace(hour=0, minute=0, second=0, microsecond=0)
	
	if (month_name in month_sums):
		month_sums[month_name] += log_time_in_seconds
	else:
		month_sums[month_name] = log_time_in_seconds


month_name = calendar.month_name[int(current_date.month)]
if (month_sums[month_name]):
	month_sums[month_name] += timedelta(seconds=total_time_diff)
else:
	month_sums[month_name] = timedelta(seconds=total_time_diff)

max_month_len = max(len(colored(month, 'blue')) for month in month_sums)
max_time_len = max(len(colored(f'{h:d}:{m:02d}', 'green')) for h, m, _ in [(total_time_delta.seconds // 3600, (total_time_delta.seconds // 60) % 60, 0) for total_time_delta in month_sums.values()])


for month, total_time_delta in month_sums.items():
    total_seconds = int(total_time_delta.total_seconds())
    m, s = divmod(total_seconds, 60)
    h, m = divmod(m, 60)
    formatted_time = f'{h:d}h:{m:02d}'
    total_length = len(f'{month}: {formatted_time}')
    colored_month = colored(month, 'blue')  # Apply blue color to month name
    colored_time = colored(formatted_time, 'green')  # Apply green color to time
    print(f'{colored_month}: {colored_time}'.rjust(max_month_len + max_time_len + 4))
