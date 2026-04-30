# Baseline Environment

基线环境，包含完整的 15 个微服务。

## 部署方式

```bash
kubectl apply -f k8s/baseline/
kubectl apply -f k8s/istio/
```

## 标签说明

所有 Pod 都带有 `env: baseline` 标签，用于 Istio 路由识别。

## 流量路由

- 默认流量：路由到 baseline 子集
- 泳道流量：当请求携带 `x-env` Header 时，优先路由到对应泳道，不存在则 fallback 到 baseline
