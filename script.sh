#!/bin/bash
# https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28

commentId=

# Function to create a comment
createComment() {
  if [ -z "$issueNumber" ] || [ -z "$body" ]; then
    echo "Issue number and comment body are required."
    return
  fi

  # Create a comment
  gh pr comment $issueNumber --body "$body"
  status=$?

  if [ $status -ne 0 ]; then
    echo "Failed to create a comment. Exit code: $status"
    return
  fi

  echo "Created a comment on issue number: $issueNumber"
  echo "Create comment exit code: $status"
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

}

# Function to delete a comment
deleteComment() {
  echo "hello delete"
  if [ -z "$comment_Id" ]; then
    echo "Comment ID is required."
    return
  fi

  # Delete the comment
   gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/${repo}/issues/comments/${comment_Id}

  STATUS=$?

  if [ "$STATUS" -ne 0 ]; then
    echo "Failing deployment"
    exit $STATUS1
  else
    echo "Deleted a comment. Comment ID: $comment_Id"   
  fi 
}

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

# These outputs are used in other steps/jobs via action.yml
echo "comment_id=${commentId}" >> $GITHUB_OUTPUT
