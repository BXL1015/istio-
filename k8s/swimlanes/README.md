# 泳道环境目录

此目录存放所有泳道环境的配置文件。

## 目录结构

```
k8s/swimlanes/
├── set1/              # 泳道 set1
│   ├── README.md
│   ├── svc3.yaml
│   └── svc5.yaml
├── set2/              # 泳道 set2
│   └── ...
└── README.md
```

## 创建新泳道

### 方式一：GitHub Actions

在 GitHub 仓库页面，进入 Actions → 创建泳道环境，填写参数并运行。

### 方式二：本地脚本

```powershell
./scripts/create-swimlane.ps1 -Name set2 -Services "svc3,svc7"
```

## CI 自动做的事情

创建泳道时，CI 会：

1. **生成泳道 Deployment**
   - `k8s/swimlanes/set1/svc3.yaml`
   - `k8s/swimlanes/set1/svc5.yaml`

2. **Patch Istio 配置**
   - `k8s/istio/destination-rule-svc3.yaml` → 添加 set1 subset
   - `k8s/istio/virtualservice-svc3.yaml` → 添加 set1 route
   - `k8s/istio/destination-rule-svc5.yaml` → 添加 set1 subset
   - `k8s/istio/virtualservice-svc5.yaml` → 添加 set1 route

3. **Git commit & push**

4. **ArgoCD 自动同步**

## 泳道命名规范

- 使用小写字母、数字和连字符
- 例如：`set1`, `set2`, `feature-101`, `hotfix-abc`
- 不能使用 `baseline`（保留给基线环境）
