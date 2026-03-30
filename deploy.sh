#!/bin/bash
echo "미리보기를 열게요..."
open "$1"

echo ""
echo "배포할까요? (y/n)"
read answer

if [ "$answer" = "y" ]; then
  git add .
  git commit -m "docs: $(date '+%Y-%m-%d %H:%M')"
  git push origin main
  echo "완료! https://eunnwk.github.io/docs"
else
  echo "취소"
fi
