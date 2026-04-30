# K8S Manifest Repository

此目录按环境组织 Kubernetes 配置文件。

## 目录结构

```
k8s/
├── baseline/                       # 基线环境 (set0)
│   ├── svc1.yaml
│   ├── svc2.yaml
│   └── ...
├── istio/                          # Istio 路由配置
│   ├── destination-rule-svc1.yaml  # 每个服务一个 DestinationRule
│   ├── virtualservice-svc1.yaml    # 每个服务一个 VirtualService
│   └── ...
└── swimlanes/                      # 泳道环境
    ├── set1/                       # 泳道 set1
    │   ├── svc3.yaml
    │   └── svc5.yaml
    ├── set2/                       # 泳道 set2
    └── ...
```

## 环境说明

### baseline (基线环境)

- 包含完整的 15 个微服务
- 所有 Pod 带有 `env: baseline` 标签
- 作为所有泳道的 fallback 目标

### istio (路由配置)

- **destination-rule-svc*.yaml**: 每个服务独立的 DestinationRule
- **virtualservice-svc*.yaml**: 每个服务独立的 VirtualService
- 创建泳道时 CI 会自动 Patch 这些文件

### swimlanes (泳道环境)

- 只部署差异化的服务
- Pod 带有 `env: set1` 等标签
- 由 CI 自动生成

## 部署顺序

```bash
# 1. 部署 Istio 路由规则
kubectl apply -f k8s/istio/

# 2. 部署基线环境
kubectl apply -f k8s/baseline/

# 3. 创建泳道 (通过 GitHub Actions)
# ArgoCD 会自动同步
```

## ArgoCD 配置

参见 [argocd-appset.yaml](../argocd-appset.yaml)

- **ApplicationSet (baseline)**: 管理基线环境
- **ApplicationSet (swimlanes)**: 自动发现泳道目录
- **Application (istio-routing)**: 管理 Istio 配置
