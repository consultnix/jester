module(..., package.seeall)

--[[
  Initialize the navigation module.
]]
function init()
  -- Initialize navigation stack.
  jester.reset_stack("navigation")

  -- Register clearing the stack on hangup.
  local event = {}
  event.event_type = "action"
  event.action = {
    action = "navigation_clear",
    ad_hoc = true,
  }
  -- We want this to be cleared before any user hangup sequences/actions are
  -- run, so force it into first position.
  table.insert(jester.channel.stack.exit, 1, event)
end

--[[
  Log the current navigation stack.
]]
function show_navigation_stack(stack)
  jester.debug_log("Current navigation stack: %s", table.concat(stack, " | "))
end

--[[
  Add a sequence to the navigation stack.
]]
function add_to_stack(action)
  local stack = jester.channel.stack.navigation
  local sequence_stack = jester.channel.stack.sequence
  local p = jester.channel.stack.sequence_stack_position
  -- Default to the currently running sequence.
  local sequence = action.sequence or (sequence_stack[p].name .. " " .. sequence_stack[p].args)
  -- Don't add to the stack if the last sequence on the stack is the same.
  if not (sequence == stack[#stack]) then
    table.insert(jester.channel.stack.navigation, sequence)
    jester.debug_log("Adding '%s' to navigation stack", sequence)
    show_navigation_stack(stack)
  end
end

--[[
  Go up the navigation stack one level.
]]
function navigation_up(action)
  local stack = jester.channel.stack.navigation
  if #stack == 0 then
    jester.debug_log("Cannnot navigate up the stack, stack is empty!")
  else
    local last_sequence, new_sequence
    -- Remove the current sequence from the stack unless it's the only one.
    if #stack > 1 then
      last_sequence = table.remove(jester.channel.stack.navigation)
    end
    -- Last item on the stack is now up one level.
    new_sequence = stack[#stack]
    jester.debug_log("Moving up the stack from sequence '%s' to sequence '%s'", tostring(last_sequence), new_sequence)
    show_navigation_stack(stack)
    jester.queue_sequence(new_sequence)
  end
end

--[[
  Clear the navigation stack.
]]
function navigation_clear(action)
  jester.channel.stack.navigation = {}
  jester.debug_log("Navigation stack cleared.")
end

--[[
  Go to the top of the navigation stack.
]]
function navigation_top(action)
  local stack = jester.channel.stack.navigation
  if #stack == 0 then
    jester.debug_log("Cannnot navigate to the top of the stack, stack is empty!")
  else
    local last_sequence, new_sequence
    last_sequence = stack[#stack]
    new_sequence = stack[1]
    -- New stack starts with first sequence from old stack.
    jester.channel.stack.navigation = { new_sequence }
    jester.debug_log("Moving to top of stack from sequence '%s' to sequence '%s'", last_sequence, new_sequence)
    jester.queue_sequence(new_sequence)
  end
end

--[[
  Set the last item on the navigation stack as the new top.
]]
function navigation_reset(action)
  local stack = jester.channel.stack.navigation
  if #stack == 0 then
    jester.debug_log("Cannnot reset stack, stack is empty!")
  else
    -- New stack starts with last sequence from old stack.
    new_sequence = table.remove(stack)
    jester.channel.stack.navigation = { new_sequence }
    jester.debug_log("Reset top of stack to sequence '%s'", new_sequence)
  end
end

-- Make sure module initialization only runs once.
if not jester.modules.navigation.navigation.init_run then
  jester.modules.navigation.navigation.init_run = true
  init()
end

