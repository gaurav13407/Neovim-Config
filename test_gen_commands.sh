#!/bin/bash

echo "🧪 Testing Gen Commands..."
echo ""

# Test 1: Check if commands are registered
echo "📋 Test 1: Checking command registration..."
nvim --headless -c "
lua << EOF
local success = pcall(function()
  -- Load gen.lua config
  local gen_config = require('Gaurav.plugins.gen')
  gen_config.config(nil, gen_config.opts)
  
  -- Check if commands exist
  local commands = {'GenQwen', 'GenDeepSeek', 'GenPhi', 'GenChat', 'GenExplain', 'GenFix', 'GenReview'}
  for _, cmd in ipairs(commands) do
    local exists = vim.fn.exists(':' .. cmd) == 2
    if exists then
      print('✅ :' .. cmd .. ' registered')
    else
      print('❌ :' .. cmd .. ' NOT registered')
    end
  end
end)

if not success then
  print('❌ Failed to load gen.lua')
end
EOF
" -c "qa" 2>&1 | grep -E "(✅|❌)"

echo ""
echo "📋 Test 2: Checking gen.nvim plugin..."
if command -v ollama &> /dev/null; then
  echo "✅ Ollama CLI found"
  
  # Check if ollama is running
  if curl -s http://localhost:11434/api/tags &> /dev/null; then
    echo "✅ Ollama server running"
    
    # Check models
    echo ""
    echo "📦 Available models:"
    ollama list | grep -E "(qwen|deepseek|phi)" || echo "⚠️  No AI models found"
  else
    echo "⚠️  Ollama server not running (start with: ollama serve)"
  fi
else
  echo "❌ Ollama not installed"
fi

echo ""
echo "📋 Test 3: Manual test instructions..."
echo "To test the fix manually:"
echo "1. Open Neovim"
echo "2. Type :GenQwen and press Enter"
echo "3. You should see:"
echo "   - Notification with model name"
echo "   - Context summary"
echo "   - Input prompt for your query (NOT a model selection menu)"
echo "4. After response, you'll be prompted to continue"
echo ""
echo "Quick test: nvim +GenQwen"
