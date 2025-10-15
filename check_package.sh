#!/bin/bash

echo "🔍 com.example 검색 중..."
echo ""

echo "1️⃣ AndroidManifest.xml 확인"
echo "================================"
grep -n "com.example" android/app/src/main/AndroidManifest.xml 2>/dev/null || echo "✅ 없음"
grep -n "com.example" android/app/src/debug/AndroidManifest.xml 2>/dev/null || echo "✅ 없음"
grep -n "com.example" android/app/src/profile/AndroidManifest.xml 2>/dev/null || echo "✅ 없음"
echo ""

echo "2️⃣ build.gradle 확인"
echo "================================"
grep -n "com.example" android/app/build.gradle 2>/dev/null || echo "✅ 없음"
grep -n "com.example" android/settings.gradle 2>/dev/null || echo "✅ 없음"
grep -n "com.example" android/build.gradle 2>/dev/null || echo "✅ 없음"
echo ""

echo "3️⃣ 폴더 구조 확인"
echo "================================"
if [ -d "android/app/src/main/kotlin/com/example" ]; then
    echo "❌ com.example 폴더 존재!"
    ls -la android/app/src/main/kotlin/com/example/
else
    echo "✅ com.example 폴더 없음"
fi

if [ -d "android/app/src/main/java/com/example" ]; then
    echo "❌ java/com.example 폴더 존재!"
    ls -la android/app/src/main/java/com/example/
else
    echo "✅ java/com.example 폴더 없음"
fi

if [ -d "android/app/src/main/kotlin/com/doythan/bookmarkmanager" ]; then
    echo "✅ doythan/bookmarkmanager 폴더 존재"
    ls -la android/app/src/main/kotlin/com/doythan/bookmarkmanager/
else
    echo "❌ doythan/bookmarkmanager 폴더 없음!"
fi
echo ""

echo "4️⃣ Firebase 설정 확인"
echo "================================"
cat android/app/google-services.json | grep "package_name"
echo ""

echo "5️⃣ 전체 파일에서 com.example 검색"
echo "================================"
grep -r "com\.example" android/ 2>/dev/null | grep -v ".gradle/" | grep -v "build/"
