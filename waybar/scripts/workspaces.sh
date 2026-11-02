#!/usr/bin/env bash

tags=$(mmsg get all-tags)

jq -c '
  [
    .all_tags[].tags[]
    | {
        id: .index,
        occupied: (.client_count > 0),
        active: .is_active,
        urgent: .is_urgent
      }
  ]
  | group_by(.id)
  | map(
      .[0] as $first
      | {
          id: $first.id,
          occupied: any(.[]; .occupied),
          active: any(.[]; .active),
          urgent: any(.[]; .urgent)
        }
    )
  | map(select(.id <= 5 or .occupied))
' <<< "$tags"
