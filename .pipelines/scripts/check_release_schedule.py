import sys
from datetime import datetime, timedelta
from msrest.authentication import BasicAuthentication
from azure.devops.connection import Connection
from azure.devops.v7_0.task_agent.models import VariableGroupParameters

ORGANIZATION_NAME = "athenat"
ATHENA_PROJECT_ID = "ede58de8-5d83-4b61-9288-35b324e47e30"
ATHENA_PROJECT_NAME = "athena"
VARIABLE_GROUP_NAME = "lightrun-helm-chart-variables"
VARIABLE_GROUP_ID = 45


def parse_date(date_str):
    """Parse YYYY-MM-DD or YYYY-M-D into datetime.date"""
    try:
        year, month, day = map(int, date_str.split('-'))
        return datetime(year, month, day).date()
    except ValueError as e:
        raise ValueError(f"Invalid date format: {date_str}, correct format: YYYY-MM-DD") from e


def get_variable_group(client, group: str):
    variable_groups = client.get_variable_groups(project=ATHENA_PROJECT_NAME, group_name=group)
    if not variable_groups:
        raise ValueError(f"No variable group found with name '{group}' in project '{ATHENA_PROJECT_NAME}'.")
    
    return variable_groups[0]


def update_variable_group(variable_group, client, updates: dict):
    """
    Update (or insert) variables in an existing variable group.

    Args:
        variable_group: The existing VariableGroup object.
        client: The client used to update the variable group.
        updates (dict): Variables to update or insert.
                        Example: {"var_name": "new_value"} or {"var_name": None}
    """
    vg: dict = variable_group.as_dict()

    for key, val in updates.items():
        vg["variables"][key] = {"value": val}

    vg["variable_group_project_references"] = [
        {
            "name": variable_group.name,
            "project_reference": {
                "id": ATHENA_PROJECT_ID,
                "name": ATHENA_PROJECT_NAME
            }
        }
    ]

    # Convert back to VariableGroupParameters
    parameters = VariableGroupParameters.from_dict(vg)

    # Note: this action removes the description of the variable group
    client.update_variable_group(
        variable_group_parameters=parameters,
        group_id=VARIABLE_GROUP_ID
    )

    print("Variable group updated.")


def fetch_release_dates(variable_group):
    """Extract and parse NEXT_RELEASE_DATE and OVERRIDE_RELEASE_DATE from a variable group."""
    try:
        next_release = variable_group.variables['NEXT_RELEASE_DATE'].value
        override_release = variable_group.variables['OVERRIDE_RELEASE_DATE'].value
    except KeyError as e:
        raise KeyError(f"Missing variable in group '{VARIABLE_GROUP_NAME}': {e}")
    
    # Log and enforce NEXT_RELEASE_DATE presence
    if not next_release or (isinstance(next_release, str) and not next_release.strip()):
        print("NEXT_RELEASE_DATE is not set, exiting...")
        sys.exit(1)
    else:
        print(f"NEXT_RELEASE_DATE = {next_release}")

    # Log OVERRIDE_RELEASE_DATE status
    if not override_release or (isinstance(override_release, str) and not override_release.strip()):
        print("OVERRIDE_RELEASE_DATE is not set, ignoring it.")
        override_release = None
    else:
        print(f"OVERRIDE_RELEASE_DATE = {override_release}")

    if isinstance(next_release, str):
        next_release = parse_date(next_release)
    if override_release and isinstance(override_release, str):
        override_release = parse_date(override_release)
    
    return next_release, override_release


def main():
    if len(sys.argv) < 2:
        print("Usage: check_release_schedule.py <AZURE_DEVOPS_PAT_RW>")
        sys.exit(1)
    pat = sys.argv[1]

    organization_url = f"https://dev.azure.com/{ORGANIZATION_NAME}"
    credentials = BasicAuthentication('', pat)
    connection = Connection(base_url=organization_url, creds=credentials)
    task_agent_client = connection.clients.get_task_agent_client()

    variable_group = get_variable_group(client=task_agent_client, group=VARIABLE_GROUP_NAME)
    NEXT_RELEASE_DATE, OVERRIDE_RELEASE_DATE = fetch_release_dates(variable_group)
    current_date = datetime.utcnow().date()

    if OVERRIDE_RELEASE_DATE:
        delta_days = abs((NEXT_RELEASE_DATE - OVERRIDE_RELEASE_DATE).days)

        if delta_days > 13:
            print(f"OVERRIDE_RELEASE_DATE ({OVERRIDE_RELEASE_DATE}) is {delta_days} days away from NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}).\n"
                f"Max delta allowed is 13 days, deleting value of OVERRIDE_RELEASE_DATE and exiting.")

            updates = {
                "OVERRIDE_RELEASE_DATE": None
            }
            update_variable_group(variable_group, task_agent_client, updates)

            sys.exit(1)

        print(f"OVERRIDE_RELEASE_DATE ({OVERRIDE_RELEASE_DATE}) has priority over NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}) and will be used.")
        if current_date != OVERRIDE_RELEASE_DATE:
            sys.exit(2)  # exit if today is not the override date
        
        next_release_date_plus_2_weeks = NEXT_RELEASE_DATE + timedelta(weeks=2)
        updates = {
                "NEXT_RELEASE_DATE": next_release_date_plus_2_weeks,
                "OVERRIDE_RELEASE_DATE": None
            }
        update_variable_group(variable_group, task_agent_client, updates)

    elif NEXT_RELEASE_DATE:
        print(f"Using NEXT_RELEASE_DATE ({NEXT_RELEASE_DATE}) since OVERRIDE_RELEASE_DATE is None.")
        if current_date != NEXT_RELEASE_DATE:
            sys.exit(2)  # exit if today is not the next release date
    
        next_release_date_plus_2_weeks = NEXT_RELEASE_DATE + timedelta(weeks=2)
        updates = {
                "NEXT_RELEASE_DATE": next_release_date_plus_2_weeks
            }
        update_variable_group(variable_group, task_agent_client, updates)


if __name__ == "__main__":
    main()
