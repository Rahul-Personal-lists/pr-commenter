#!/bin/bash

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
  commentId=$(echo "$comment" | awk -F'/' '{print $NF}' | cut -d'-' -f2)

  echo "Comment is modified. Comment ID: $commentId"

  addReactions
}

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

echo "owner=$owner"
echo "repo=$repo"
echo "commentId=$commentId"
echo "issueNumber=$issueNumber"
#foundComment=$(gh api "/repos/$owner/$repo/issues/comments/$commentId" -H "Authorization: token $GH_TOKEN")
  # if [ "$direction" == "older" ]; then
  #   comments=$(curl -s -H "Authorization: token $token" "https://api.github.com/repos/$owner/$repo/issues/$issueNumber/comments")

  #   for comment in $(echo "$comments" | jq -c '.[]'); do
  #     if [ -z "$searchTerm" ] || [ "$(echo "$comment" | jq -r '.body' | grep -E "$searchTerm")" ]; then
  #       if [ -z "$author" ] || [ "$(echo "$comment" | jq -r '.user.login')" == "$author" ]; then
  #         commentId=$(echo "$comment" | jq -r '.id')
  #         echo "Comment found for a search term: '$searchTerm'."
  #         echo "Comment ID: '$commentId'."
  #         return
  #       fi
  #     fi
  #   done
  # else
# comments=$(gh api \
#   -H "Accept: application/vnd.github+json" \
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   /repos/Rahul-Personal-lists/copy-giftree/pulls/comments)
comments=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/Rahul-Personal-lists/copy-giftree/pulls)

#$(curl -s -H "Authorization: token $GH_TOKEN" "https://api.github.com/repos/$owner/copy-giftree/issues/$issueNumber/comments")
echo "commentssssss=$comments"


# comment=$(echo "$comments" | jq -r '.[] | select('\
#   "(\"$searchTerm\" | length > 0 and .body | index(\"$searchTerm\") >= 0) or " \
#   "(\"$author\" | length > 0 and .user.login == \"$author\")" \
# ')')

if [ -n "$comment" ]; then
  commentId=$(echo "$comment" | jq -r '.id')
  echo "Comment found for a search term: '$searchTerm'."
  echo "Comment ID: '$commentId'."
fi

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

echo "actionType=${actionType}"
echo "issueNumber=${issueNumber}"
echo "body=${body}"


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

