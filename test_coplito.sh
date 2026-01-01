#!/bin/bash
# Test script for Coplito setup

echo "==================================="
echo "Coplito Test Suite"
echo "==================================="
echo ""

# Check Ollama is running
echo "1. Checking Ollama service..."
if pgrep -f "ollama serve" > /dev/null; then
    echo "   ✅ Ollama is running"
else
    echo "   ❌ Ollama is NOT running"
    echo "   Run: ollama serve > /dev/null 2>&1 &"
    exit 1
fi
echo ""

# Check models
echo "2. Checking installed models..."
ollama list
echo ""

# Test each model with a simple query
echo "3. Testing model responses..."

echo "   Testing Qwen 2.5 Coder 14B..."
qwen_response=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:14b",
  "prompt": "Say OK",
  "stream": false
}' | grep -o '"response":"[^"]*"' | head -1)
if [ -n "$qwen_response" ]; then
    echo "   ✅ Qwen responding"
else
    echo "   ❌ Qwen not responding"
fi

echo "   Testing DeepSeek Coder V2 16B..."
deepseek_response=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "deepseek-coder-v2:16b",
  "prompt": "Say OK",
  "stream": false
}' | grep -o '"response":"[^"]*"' | head -1)
if [ -n "$deepseek_response" ]; then
    echo "   ✅ DeepSeek responding"
else
    echo "   ❌ DeepSeek not responding"
fi

echo "   Testing Phi 3.5 Mini..."
phi_response=$(curl -s http://localhost:11434/api/generate -d '{
  "model": "phi3.5:3.8b-mini-instruct-q4_K_M",
  "prompt": "Say OK",
  "stream": false
}' | grep -o '"response":"[^"]*"' | head -1)
if [ -n "$phi_response" ]; then
    echo "   ✅ Phi responding"
else
    echo "   ❌ Phi not responding"
fi
echo ""

# Check Neovim config files
echo "4. Checking Neovim config files..."
if [ -f ~/.config/nvim/lua/Gaurav/plugins/gen.lua ]; then
    echo "   ✅ gen.lua exists"
else
    echo "   ❌ gen.lua missing"
fi

if [ -f ~/.config/nvim/lua/Gaurav/core/keymaps.lua ]; then
    echo "   ✅ keymaps.lua exists"
else
    echo "   ❌ keymaps.lua missing"
fi
echo ""

echo "==================================="
echo "Test Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Restart Neovim: nvim"
echo "2. Try: :GenQwen"
echo "3. Try: <leader>gq"
echo "4. Try: <leader>gm (model menu)"
