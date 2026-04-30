# 微服务全链路泳道治理实验平台

基于 Istio 服务网格的全链路泳道（Swimlane）治理实验平台。

## 核心特性

- **每个服务独立配置**：每个服务有独立的 DestinationRule 和 VirtualService
- **泳道隔离**：不同泳道使用唯一标签（set1, set2...）
- **自动路由**：CI 自动 Patch Istio 配置
- **GitOps 驱动**：ArgoCD 自动同步

## 架构概览

```
┌─────────────────────────────────────────────────────────────────┐
│                        完整流程                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. 研发点击"创建泳道 set1"，选择 svc3, svc5                      │
│                    │                                             │
│                    ▼                                             │
│  2. CI 脚本执行：                                                 │
│     - 生成 swimlanes/set1/svc3.yaml, svc5.yaml                  │
│     - Patch istio/destination-rule-svc3.yaml                    │
│     - Patch istio/virtualservice-svc3.yaml                      │
│     - Patch istio/destination-rule-svc5.yaml                    │
│     - Patch istio/virtualservice-svc5.yaml                      │
│     - Git commit & push                                         │
│                    │                                             │
│                    ▼                                             │
│  3. ArgoCD 自动同步：                                             │
│     - ApplicationSet (swimlanes) 发现新目录                      │
│     - Application (istio-routing) 检测到变更                     │
│     - 自动部署到 K8s                                             │
│                    │                                             │
│                    ▼                                             │
│  4. 流量带 x-env: set1 进来：                                     │
│     - svc3 有 set1 subset → 路由到泳道                           │
│     - svc4 无 set1 subset → 走 baseline                          │
│     - svc5 有 set1 subset → 路由到泳道                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## 目录结构

```
├── k8s/
│   ├── baseline/                       # 基线环境 (完整15个服务)
│   ├── istio/                          # Istio 路由配置
│   │   ├── destination-rule-svc1.yaml  # 每个服务一个
│   │   ├── virtualservice-svc1.yaml    # 每个服务一个
│   │   └── ...
│   └── swimlanes/                      # 泳道环境
│       ├── set1/                       # 示例泳道
│       └── ...
├── .github/workflows/
│   ├── create-swimlane.yml             # 创建泳道
│   └── image-ci.yml                    # 构建镜像
├── argocd-appset.yaml                  # ArgoCD 配置
└── scripts/                            # 本地脚本
```

## ArgoCD 配置

| 组件 | 类型 | 作用 |
|------|------|------|
| baseline | ApplicationSet | 管理基线环境 |
| swimlanes | ApplicationSet | 自动发现泳道目录 |
| istio-routing | Application | 管理 Istio 配置 |

## 快速开始

### 1. 安装 Istio

```bash
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```

### 2. 部署基线环境

```bash
kubectl apply -f k8s/istio/
kubectl apply -f k8s/baseline/
```

### 3. 创建泳道

在 GitHub Actions 页面点击"创建泳道环境"，填写：
- 泳道名称：`set1`
- 服务列表：`svc3,svc5`
- 镜像标签：`main`

### 4. 验证

```bash
# 基线请求
curl http://<svc1-ip>:9000/?n=10

# 泳道请求
curl -H "x-env: set1" http://<svc1-ip>:9000/?n=10
```

## Istio 配置示例

### DestinationRule

```yaml
subsets:
  - name: baseline
    labels:
      env: baseline
  - name: set1          # CI 自动添加
    labels:
      env: set1
```

### VirtualService

```yaml
http:
  - match:
      - headers:
          x-env:
            exact: set1
    route:
      - destination:
          subset: set1
  - route:                      # 默认走基线
      - destination:
          subset: baseline
```

## 常用命令

```bash
# 查看所有服务
kubectl get pods -l app

# 查看泳道服务
kubectl get pods -l env=set1

# 查看 Istio 路由
kubectl get virtualservice
kubectl get destinationrule
```
