valid_extension_sequence = args(1)
invalid_extension_sequence = args(2)
extension = storage("get_digits", "extension")
loaded_mailbox = storage("mailbox_settings_message", "mailbox")

return
{
  {
    action = "get_digits",
    min_digits = 3,
    max_digits = 20,
    audio_files = "phrase:extension",
    bad_input = "",
    storage_key = "extension",
  },
  {
    action = "call_sequence",
    sequence = "sub:load_mailbox_settings " .. extension .. "," .. profile.domain .. ",mailbox_settings_message",
  },
  {
    action = "conditional",
    value = loaded_mailbox,
    compare_to = "",
    comparison = "equal",
    if_false = valid_extension_sequence,
    if_true = "invalid_extension " .. invalid_extension_sequence,
  },
}
