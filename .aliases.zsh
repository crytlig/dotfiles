#!/bin/zsh

## Terraform
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfip='terraform init && terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfda='terraform destroy -auto-approve'
alias tfc='terraform console'

alias nopencode='nix run nixpkgs#opencode'

myip() {
  local ip=$(curl -s icanhazip.com)

  if [ $(uname) = "Darwin" ]; then
    echo $ip | tee >(pbcopy)
  else
    echo "$ip" | tee >(xclip -selection clipboard)
  fi
}

## Stupid aliases basically to just open nv in temporary
## mode and write to same files again and again
alias standup='nv ~/repos/next/documents/stand_up'

delete_workflow_runs() {
    set -eo pipefail

    error_exit() {
        echo -e "$1" 1>&2
        return 1
    }

    owner_repo=$(gh repo view --json owner,name -q '.owner.login + "/" + .name') || error_exit "Failed to fetch repository information."
    owner=$(echo "$owner_repo" | cut -d'/' -f1) || error_exit "Failed to extract owner."
    repo=$(echo "$owner_repo" | cut -d'/' -f2) || error_exit "Failed to extract repository name."


    workflows=$(gh workflow list --json name,id) || error_exit "Failed to retrieve workflows."
    workflow_name=$(echo "$workflows" | jq -r '.[].name' | gum choose) || error_exit "Workflow selection failed."

    if [ -z "$workflow_name" ]; then
        error_exit "No workflow selected."
    fi

    # F*** JQ and stupid bash syntax
    workflow_id=$(echo "$workflows" | jq -r --arg name "$workflow_name" '.[] | select(.name == $name) | .id') || error_exit "Failed to extract workflow ID."
    echo "Selected Workflow : $workflow_name ($workflow_id)"

    deletions=$(gum choose 1 2 3 5 10 20 25 --header="Choose number of deletions to make")

    echo "Deleting $deletions workflow runs from $workflow_name"
    # F*** this jq and xargs syntax in particular.............
    gh api -X GET "/repos/$owner/$repo/actions/workflows/$workflow_id/runs?per_page=$deletions" | jq '.workflow_runs[] | .id' -r \
    | xargs -t -I{} gh api --silent -X DELETE "/repos/$owner/$repo/actions/runs/{}" || error_exit "Failed to delete workflow run."
}

tns() {
    local name="${1:?session name}"
    local dir="${2:-.}"
    # Replace any ~ with HOME dir. Tmux does not expand properly
    dir="${dir/#\~/$HOME}"
    tmux new-session -d -s "$name" -c "$dir"
}

qme() {
    if [ -z $1 ]; then
        echo 'need arg for question'
        return
    fi

    pi --model "github-copilot/gpt-5.4-mini" -p "$1"
}
