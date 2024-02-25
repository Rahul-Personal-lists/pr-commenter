#!/bin/bash
# https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28

commentId=''
# Function to add reactions
addReactions() {
  if [ -z "$reactions" ]; then
    return
  fi

  IFS=',' read -ra reactionsArray <<< "$reactions"
  for reaction in "${reactionsArray[@]}"; do
    # Validate reaction
    if [[ ! " ${allowedReactions[@]} " =~ " $reaction " ]]; then
      echo "Invalid reaction: '$reaction'"
      continue
    fi

    # React on a comment
    echo "Reacted '$reaction' on a comment."
    # Add your command to react here
  done
}

# Function to create a comment
createComment() {
  if [ -z "$issueNumber" ] || [ -z "$body" ]; then
    echo "Issue number and comment body are required."
    return
  fi

  # Create a comment

  comment=$(gh pr comment $issueNumber --body "$body")
  
  echo "Created a comment on issue number: $issueNumber"
  echo "Create comment=$comment"
  id=$(echo "$comment" | awk -F'/' '{print $NF}' | cut -d'-' -f2)

  echo "Comment is modified. Comment ID: $id"

  addReactions
}

# Function to find a comment
findComment() {
  if [ -z "$issueNumber" ]; then
    echo "Issue number is required."
    return
  fi

  if [ -z "$searchTerm" ] && [ -z "$author" ]; then
    echo "Either search term or comment author is required."
    return
  fi

comments=$(gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/$repo/issues/10/comments)

comment_body=$(echo "$comments" | jq -r '.[0].body')

echo "CommentBody: $comment_body"

if [ -n "$comment_body" ]; then
  commentId=$(echo "$comments" | jq -r '.[0].id')
  echo "Comment found for a search term: '$searchTerm'."
  echo "Comment ID: '$commentId'."
fi

commentId

}

# Function to delete a comment
# deleteComment() {
#   if [ -z "$commentId" ]; then
#     echo "Comment ID is required."
#     return
#   fi

#   # Delete the comment
#   curl -s -H "Authorization: token $token" \
#     -X DELETE "https://api.github.com/repos/$owner/$repo/issues/comments/$commentId"

#   echo "Deleted a comment. Comment ID: $commentId"
# }


allowedReactions=("\\+1" "-1" "laugh" "hooray" "confused" "heart" "rocket" "eyes")

case $actionType in
  "create")
    createComment ;;
  "update" | "append" | "prepend")
    updateComment ;;
  "find")
    findComment ;;
  "delete")
    deleteComment ;;
  *)
    echo "Invalid action type: $actionType" ;;
esac

echo "comment_id: $commentId"
echo "comment_body: $commentBody"

# These outputs are used in other steps/jobs via action.yml
echo "comment_id=${commentId}" >> $GITHUB_OUTPUT


# echo "theme_id=${THEME_IDS[@]}" >> $GITHUB_OUTPUT



# Function to update a comment
# updateComment() {
#   if [ -z "$commentId" ] || [ -z "$body" ]; then
#     echo "Comment ID and comment body are required."
#     return
#   fi

#   # Get existing comment
#   comment=$(curl -s -H "Authorization: token $token" \
#     "https://api.github.com/repos/$owner/$repo/issues/comments/$commentId")

#   if [ "$actionType" == "append" ]; then
#     newComment=$(echo -e "${comment['body']}\n$body")
#   elif [ "$actionType" == "prepend" ]; then
#     newComment=$(echo -e "$body\n${comment['body']}")
#   else
#     newComment=$body
#   fi

#   # Update the comment
#   comment=$(curl -s -H "Authorization: token $token" \
#     -X PATCH -d "{\"body\": \"$newComment\"}" \
#     "https://api.github.com/repos/$owner/$repo/issues/comments/$commentId")

#   commentId=$(echo "$comment" | jq -r '.id')
#   echo "Comment is modified. Comment ID: $commentId"

#   addReactions
# }
