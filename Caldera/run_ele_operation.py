import requests
from datetime import datetime
import time
import os

CALDERA_URL = 'http://127.0.0.1:8888/api/v2'
API_KEY = 'ADMIN123'
PROFILE_NAME_ELE = 'ELE'
ADVERSARY_ID_ELE = '3552a5ee-8a8c-41fb-9182-0c44f05a5fb2'
PLANNER_ID = 'aaa7c857-37a0-4c4a-85f7-4e9f7f30e31a'
SOURCE_ID_ELE = '605826b8-6f70-4e3a-882d-0f9d69934e78'
KNOWN_AGENTS_FILE = 'known_agents.txt'
LOG_FILE = 'operation_log.txt'
AGENT_GROUP = 'coinworm'
OPERATION_INTERVAL = 600  # 10 minutes

def load_known_agents():
    if os.path.exists(KNOWN_AGENTS_FILE):
        with open(KNOWN_AGENTS_FILE, 'r') as file:
            return set(file.read().splitlines())
    return set()

def save_known_agents(known_agents):
    with open(KNOWN_AGENTS_FILE, 'w') as file:
        file.write('\n'.join(known_agents))

def log_message(message):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    with open(LOG_FILE, 'a') as log:
        log.write(f'{timestamp} - {message}\n')
    print(message)

def delete_dead_agents():
    try:
        headers = {'Key': API_KEY}
        response = requests.get(f'{CALDERA_URL}/agents', headers=headers)
        response.raise_for_status()
        agents = response.json()

        for agent in agents:
            if not agent.get('trusted', False):
                agent_id = agent.get('paw')
                del_response = requests.delete(f'{CALDERA_URL}/agents/{agent_id}', headers=headers)
                if del_response.status_code in (200, 204):
                    log_message(f'Deleted dead agent: {agent_id}')
    except Exception as e:
        log_message(f'Error deleting dead agents: {e}')

def delete_old_ele_operations():
    try:
        headers = {'Key': API_KEY}
        response = requests.get(f'{CALDERA_URL}/operations', headers=headers)
        response.raise_for_status()
        operations = response.json()

        for op in operations:
            if op['name'].startswith(PROFILE_NAME_ELE):
                del_resp = requests.delete(f'{CALDERA_URL}/operations/{op["id"]}', headers=headers)
                if del_resp.status_code in (200, 204):
                    log_message(f'Deleted old operation: {op["name"]}')
    except Exception as e:
        log_message(f'Error deleting old operations: {e}')

def create_ELE_operation():
    try:
        headers = {
            'Key': API_KEY,
            'Content-Type': 'application/json'
        }
        now = datetime.now()
        operation_name = f'{PROFILE_NAME_ELE}-{now.strftime("%Y-%m-%d-%H-%M-%S")}'

        payload = {
            'name': operation_name,
            'adversary': {'adversary_id': ADVERSARY_ID_ELE},
            'planner': {'id': PLANNER_ID},
            'source': {'id': SOURCE_ID_ELE},
            'auto_close': True
        }

        response = requests.post(f'{CALDERA_URL}/operations', json=payload, headers=headers)
        response.raise_for_status()

        if response.status_code in (200, 201):
            log_message(f'Successfully created {PROFILE_NAME_ELE} operation: {operation_name}')
        else:
            log_message(f'Unexpected response status ({response.status_code}) when creating operation.')
    except requests.exceptions.RequestException as e:
        log_message(f'Error occurred while creating ELE operation: {e}')

def monitor_and_run():
    known_agents = load_known_agents()

    while True:
        try:
            # Always delete dead agents first
            delete_dead_agents()

            # Re-fetch agents after cleanup
            response = requests.get(f'{CALDERA_URL}/agents', headers={'Key': API_KEY})
            response.raise_for_status()
            agents = response.json()

            # Detect new agents
            new_agents = [agent for agent in agents if agent['paw'] not in known_agents]
            for agent in new_agents:
                known_agents.add(agent['paw'])
                log_message(f'New agent onboarded: {agent["paw"]}')
            save_known_agents(known_agents)

            # Filter coinworm agents
            coinworm_agents = [a for a in agents if a.get('group') == AGENT_GROUP and a.get('trusted', True)]
            if coinworm_agents:
                delete_old_ele_operations()
                create_ELE_operation()
            else:
                log_message("No active 'coinworm' agents found. Skipping operation.")

        except requests.exceptions.RequestException as e:
            log_message(f'Error while monitoring agents: {e}')

        time.sleep(OPERATION_INTERVAL)

if __name__ == '__main__':
    monitor_and_run()
