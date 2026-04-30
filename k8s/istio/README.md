# Istio 路由配置

此目录包含所有 Istio 路由规则。

## 目录结构

```
k8s/istio/
├── destination-rule-svc1.yaml     # svc1 的 DestinationRule
├── destination-rule-svc2.yaml     # svc2 的 DestinationRule
├── ...
├── destination-rule-svc15.yaml    # svc15 的 DestinationRule
├── virtualservice-svc1.yaml       # svc1 的 VirtualService
├── virtualservice-svc2.yaml       # svc2 的 VirtualService
├── ...
└── virtualservice-svc15.yaml      # svc15 的 VirtualService
```

## 文件说明

### DestinationRule

定义服务的子集（subset）：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: svc3
spec:
  host: svc3
  subsets:
    - name: baseline      # 基线环境
      labels:
        env: baseline
    - name: set1          # 泳道环境（CI 自动添加）
      labels:
        env: set1
```

### VirtualService

定义路由规则：

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: svc3
spec:
  hosts:
    - svc3
  http:
    - match:
        - headers:
            x-env:
              exact: set1
      route:
        - destination:
            host: svc3
            subset: set1
    - route:                      # 默认走基线
        - destination:
            host: svc3
            subset: baseline
```

## 创建泳道时 CI 会做什么

1. **生成泳道 Deployment** → `k8s/swimlanes/set1/svc3.yaml`
2. **Patch DestinationRule** → 添加 `set1` subset
3. **Patch VirtualService** → 添加 `set1` 路由规则

## 部署方式

```bash
# 部署所有 Istio 路由规则
kubectl apply -f k8s/istio/
```

## 路由逻辑

```
请求携带 x-env: set1
        │
        ▼
┌───────────────────┐
│ VirtualService    │
│ 匹配 x-env Header │
└───────────────────┘
        │
        ▼
┌───────────────────┐
│ 有 set1 subset？  │
└───────────────────┘
        │
   ┌────┴────┐
   │         │
  有        无
   │         │
   ▼         ▼
┌─────┐   ┌──────────┐
│set1 │   │ baseline │
└─────┘   └──────────┘
```
