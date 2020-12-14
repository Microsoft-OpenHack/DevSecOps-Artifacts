#!/bin/bash

usage() { echo 'Usage: assign_attendees.sh -u <userEmails> -t <teamNumber>' 1>&2; exit 1; }

declare organization='https://dev.azure.com/DevSecOpsOH'
declare openHackGroupName='DryRun'
declare teamName='dsoohlite'

# Initialize parameters specified from command line
while getopts ":u:t:" arg; do
    case "${arg}" in

        u)
            userEmails=${OPTARG}
        ;;
        t)
            teamNumber=$(echo "${OPTARG}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        ;;

    esac
done
shift $((OPTIND-1))

declare projectName=${teamName}${teamNumber}

echo '=========================================='
echo ' VARIABLES'
echo '=========================================='
echo 'organization              = '${organization}
echo 'openHackGroupName         = '${openHackGroupName}
echo 'projectName               = '${projectName}
echo 'userEmails                = '${userEmails}
echo 'teamNumber                = '${teamNumber}
echo '=========================================='


# Add users to groups and projects
CurrentIFS=$IFS
IFS=','
read -r -a emails <<< $userEmails
echo 'userEmails: '${userEmails}

for email in ${emails[@]}
do
    echo 'email: '${email}
    memberDescriptor=`az devops user add --email-id $email --license-type stakeholder --organization $organization --send-email-invite false --query 'user.descriptor' --output tsv`
    openHackGroupDescriptor=`az devops security group list --organization $organization --scope organization --query "graphGroups[?displayName=='${openHackGroupName}'].descriptor" --output tsv`
    projectAdministratorDescriptor=`az devops security group list --organization $organization -p $projectName --scope=project --query "graphGroups[?displayName=='Project Administrators'].descriptor" --output tsv`
    buildAdministratorDescriptor=`az devops security group list --organization $organization -p $projectName --scope=project --query "graphGroups[?displayName=='Build Administrators'].descriptor" --output tsv`
    teamDescriptor=`az devops security group list --organization $organization -p $projectName --scope=project --query "graphGroups[?displayName=='${projectName} Team'].descriptor" --output tsv`
    az devops security group membership add --group-id $openHackGroupDescriptor --member-id $memberDescriptor --organization $organization
    az devops security group membership add --group-id $projectAdministratorDescriptor --member-id $memberDescriptor --organization $organization
    az devops security group membership add --group-id $buildAdministratorDescriptor --member-id $memberDescriptor --organization $organization
    az devops security group membership add --group-id $teamDescriptor --member-id $memberDescriptor --organization $organization
done

IFS=$CurrentIFS

echo 'Done!'
