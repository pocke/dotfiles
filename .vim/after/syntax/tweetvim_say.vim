if g:tweetvim_say_insert_account
  syntax match tweetvim_say_inserted_account '\v^\[[0-9a-zA-Z_]+\] :\ze '
  hi link tweetvim_say_inserted_account Ignore
endif
