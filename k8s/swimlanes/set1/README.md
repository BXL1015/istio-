# 泳道: set1

示例泳道环境，仅部署 svc3 和 svc5。

## 使用方式

```bash
curl -H "x-env: set1" http://<svc1-ip>:9000/?n=10
```

## 路由行为

- svc1, svc2: 走 baseline（泳道未部署）
- svc3: 走 set1 泳道
- svc4: 走 baseline（泳道未部署）
- svc5: 走 set1 泳道
- svc6 ~ svc15: 走 baseline（泳道未部署）
