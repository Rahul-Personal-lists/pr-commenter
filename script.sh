#!/bin/bash
# https://docs.github.com/en/rest/pulls/comments?apiVersion=2022-11-28

comment_id=

createComment() {
echo "======= Running create comment ======="
  if [ -z "$ISSUE_NUMBER" ] || [ -z "$BODY" ]; then
    echo "Issue number and comment body are required."
    return
  fi

  # Fetch existing comments for the given issue
  existing_comments=$(gh pr view "$ISSUE_NUMBER" --json comments -q '.comments[].body')

  # Check if the new comment body already exists
  if echo "$existing_comments" | grep -q "@$AUTHOR $BODY"; then
    echo "Comment already exists. Not creating again."
    return
  fi

  # Create a comment
  gh pr comment "$ISSUE_NUMBER" --body "@$AUTHOR $BODY"
  status=$?

  if [ "$status" -ne 0 ]; then
    echo "Failed to create a comment. Exit code: $status"
    return
  fi

  echo "Created a comment on issue number: $ISSUE_NUMBER"
}

# Function to find a comment
findComment() {
echo "======= Running find comment ======="
  if [ -z "$ISSUE_NUMBER" ]; then
    echo "Issue number is required."
    return
  fi

  if [ -z "$SEARCH_TERM" ] && [ -z "$AUTHOR" ]; then
    echo "Either search term or comment author is required."
    return
  fi

  comments=$(gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO/issues/$ISSUE_NUMBER/comments"
  )

  status=$?

  if [ "$status" -ne 0 ]; then
    echo "Failed to retrieve comments. Exit code: $status"
    return
  fi

  comment_body=$(echo "$comments" | jq -r '.[0].body')

  echo "CommentBody: $comment_body"

  if [ -n "$comment_body" ]; then
    comment_id=$(echo "$comments" | jq -r '.[0].id')
    echo "Comment found for a search term: '$SEARCH_TERM'."
    echo "Comment ID: '$comment_id'."
  else
    echo "No comment found for the given criteria."
  fi
}

# Function to delete a comment
echo "======= Running delete comment ======="
deleteComment() {
  if [ -z "$COMMENT_ID" ]; then
    echo "Comment ID is required."
    return
  fi

  # Delete the comment
  gh api \
    --method DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO/issues/comments/$COMMENT_ID"
  
  STATUS=$?

  if [ "$STATUS" -ne 0 ]; then
    echo "Failing deployment"
    exit $STATUS
  else
    echo "Deleted a comment. Comment ID: $COMMENT_ID"
  fi
}

case $ACTION_TYPE in
  "create")
    createComment ;;
  "update" | "append" | "prepend")
    updateComment ;;
  "find")
    findComment ;;
  "delete")
    deleteComment ;;
  *)
    echo "Invalid action type: $ACTION_TYPE" ;;
esac

# These outputs are used in other steps/jobs via action.yml
echo "comment_id=${comment_id}" >> "$GITHUB_OUTPUT"
