#!/bin/bash

TARGET_DOMAIN="www.bilibili.com"
PUBLIC_DNS="8.8.8.8"
DESKTOP_LOG=~/Desktop/curl_tls_debug.log

echo "🔍 正在检测域名：$TARGET_DOMAIN"
echo "-----------------------------"

echo "🌐 [1] 使用默认DNS解析："
dig $TARGET_DOMAIN +short

echo -e "\n🌐 [2] 使用公共DNS（$PUBLIC_DNS）解析："
dig $TARGET_DOMAIN @$PUBLIC_DNS +short

echo -e "\n🔗 [3] Ping 域名："
ping -c 4 $TARGET_DOMAIN

IP=$(dig @$PUBLIC_DNS +short $TARGET_DOMAIN | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1)

if [[ -z "$IP" ]]; then
  echo -e "\n❌ 无法获取有效的IP地址，请检查DNS解析。"
  exit 1
fi

echo -e "\n✅ 解析到的IP：$IP"
echo -e "\n🔗 [4] Ping 解析到的IP："
ping -c 4 $IP

echo -e "\n🧪 [5] curl 访问 HTTPS（模拟浏览器）："
curl -I -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36" https://$TARGET_DOMAIN

echo -e "\n🔍 [6] curl -v 显示握手过程（TLS检测）："
curl -v --resolve $TARGET_DOMAIN:443:$IP https://$TARGET_DOMAIN 2>&1 | tee "$DESKTOP_LOG"

echo -e "\n🛰️  [7] Traceroute 路由追踪："
traceroute $TARGET_DOMAIN

echo -e "\n✅ 诊断完成，日志已保存到：$DESKTOP_LOG"
