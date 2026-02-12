[English](README.md) | **Русский**

[![Terraform Apply](https://github.com/itcaat/terraform-kubernetes-desktop-startkit/actions/workflows/k8s.yml/badge.svg)](https://github.com/itcaat/terraform-kubernetes-desktop-startkit/actions/workflows/k8s.yml)

# Terraform Kubernetes — Стартовый набор для Docker Desktop

Стартовый набор для локальных экспериментов с Kubernetes с помощью Terraform. Включает преднастроенное управление сертификатами, маршрутизацию через ingress и балансировку нагрузки — всё для удобного тестирования, обучения и прототипирования cloud-native развёртываний.

![alt text](.github/images/image01.png)

## Для кого это?
- DevOps-инженеры и SRE, которым нужна песочница для тестирования инфраструктурной автоматизации.
- Разработчики, изучающие деплой в Kubernetes без облачных затрат.
- Команды, осваивающие лучшие практики Terraform и Kubernetes в безопасном локальном окружении.

## Что мы будем делать

К концу этого руководства у вас будет полностью рабочий локальный Kubernetes-кластер со следующими компонентами:

1. **MetalLB** — балансировщик нагрузки, который назначает реальные IP-адреса сервисам в локальном кластере (в облаке это делает облачный провайдер, но локально нужен MetalLB).
2. **Ingress-Nginx** — ingress-контроллер, который маршрутизирует входящий HTTP/HTTPS трафик к нужным сервисам на основе hostname и пути.
3. **cert-manager** — оператор, автоматизирующий создание и обновление TLS-сертификатов.
4. **ClusterIssuer (self-signed)** — использует ваш локальный CA от mkcert для выпуска сертификатов, которым доверяет браузер.
5. **ClusterIssuer (production)** — преднастроенный issuer для Let's Encrypt (готов для реальных доменов).
6. **Echo Server** — демо-приложение, которое возвращает JSON-ответ с деталями входящего запроса. Оно служит сквозным тестом: если вы можете открыть `https://echo.127.0.0.1.nip.io` и получить JSON-ответ по HTTPS с валидным сертификатом — значит весь стек работает: DNS, балансировка нагрузки, маршрутизация через ingress, TLS-сертификаты и само приложение.

Всё это описано как Terraform-код в виде отдельных модулей, поэтому позже вы сможете легко добавить свои приложения, следуя тому же паттерну, что и echo-сервер.

## Структура проекта

### **Окружения**
- `envs/local` — локальное окружение. Можно использовать Docker Desktop.

### **Модули**
Каждый сервис оформлен как отдельный модуль для лучшей переиспользуемости и организации.

| Модуль | Описание |
|--------|----------|
| `modules/metallb` | Разворачивает **MetalLB** через Helm. Динамически настраивает пулы IP-адресов с помощью `kubectl_manifest`. |
| `modules/cert-manager` | Устанавливает **Cert-Manager** через Helm. |
| `modules/ingress-nginx` | Разворачивает **Ingress-Nginx** как контроллер для управления входящим трафиком. |
| `modules/cluster-issuer-selfsigned` | Создаёт **ClusterIssuer** и самоподписанный CA-сертификат. |
| `modules/cluster-issuer-production` | Создаёт **ClusterIssuer**, использующий Let's Encrypt. |
| `modules/echo-server` | Разворачивает **Echo Server** с Ingress-ресурсом и самоподписанным TLS от Cert-Manager. |

## Начало работы

### Предварительные требования

Перед началом убедитесь, что на вашем компьютере установлено следующее.

#### 1. Docker Desktop с Kubernetes

1. Установите [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Откройте Docker Desktop, перейдите в **Settings > Kubernetes**.
3. Отметьте **Enable Kubernetes** и нажмите **Apply & Restart**.
4. Дождитесь, пока индикатор Kubernetes в нижнем левом углу станет зелёным.

Проверка:
```sh
kubectl cluster-info
```
Вы должны увидеть что-то вроде:
```
Kubernetes control plane is running at https://127.0.0.1:6443
```

#### 2. Terraform

Установите [Terraform](https://developer.hashicorp.com/terraform/install) (версия >= 1.5.0).

Проверка:
```sh
terraform version
```

#### 3. mkcert

mkcert создаёт локально доверенные сертификаты для разработки. Утилита автоматически устанавливает локальный CA в системное хранилище доверенных сертификатов.

| ОС | Команда |
|----|---------|
| macOS | `brew install mkcert` |
| Linux | `sudo apt install -y libnss3-tools && brew install mkcert` или [собрать из исходников](https://github.com/FiloSottile/mkcert#linux) |
| Windows | `choco install mkcert` |

После установки:
```sh
mkcert -install
```

Команда `mkcert -install` добавляет корневой CA в системное хранилище. Именно это позволяет браузерам и `curl` доверять самоподписанным сертификатам.

### Шаг 1: Получить репозиторий

Форкните или клонируйте репозиторий:
```sh
git clone https://github.com/itcaat/terraform-kubernetes-desktop-startkit.git
cd terraform-kubernetes-desktop-startkit
```

### Шаг 2: Задать переменные окружения

Terraform нужен CA-сертификат и ключ от mkcert для создания самоподписанных сертификатов внутри кластера. Экспортируйте их в base64-кодировке.

**macOS / Linux:**
```sh
export TF_VAR_cluster_issuer_selfsigned_ca_cert="$(base64 < "$(mkcert -CAROOT)/rootCA.pem")"
export TF_VAR_cluster_issuer_selfsigned_ca_key="$(base64 < "$(mkcert -CAROOT)/rootCA-key.pem")"
```

**Windows (PowerShell):**
```powershell
$env:TF_VAR_cluster_issuer_selfsigned_ca_cert = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$(mkcert -CAROOT)\rootCA.pem"))
$env:TF_VAR_cluster_issuer_selfsigned_ca_key = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$(mkcert -CAROOT)\rootCA-key.pem"))
```

**Важно:** эти переменные должны быть заданы в той же сессии терминала, где вы запускаете команды Terraform. Если вы откроете новый терминал — нужно экспортировать их заново.

Вы можете добавить эти строки в `~/.zshrc`, `~/.bashrc` или профиль PowerShell, чтобы они сохранялись.

### Шаг 3: Конфигурация

Вы можете переопределить значения по умолчанию, отредактировав файл `envs/local/locals.tf`:
```hcl
locals {
  kube_config_path                     = "~/.kube/config"
  kube_context                         = "docker-desktop"
  ingress_class_name                   = "nginx"
  cluster_issuer_selfsigned            = "selfsigned"
  cluster_issuer_production            = "production"
  cluster_issuer_production_acme_email = "admin@example.com"
  root_domain                          = "127.0.0.1.nip.io"
  metallb_ip_range                     = ["127.0.0.1-127.0.0.1"]
}
```

### Шаг 4: Инициализация Terraform

Перейдите в каталог локального окружения и инициализируйте Terraform:
```sh
cd envs/local
terraform init -upgrade
```

Эта команда скачивает все необходимые провайдеры и модули Terraform. Вы должны увидеть:
```
Terraform has been successfully initialized!
```

### Шаг 5: Просмотр плана

```sh
terraform plan
```

Эта команда показывает, что Terraform создаст, не внося никаких изменений. Просмотрите вывод, чтобы понять, какие ресурсы будут развёрнуты:
- MetalLB (балансировщик нагрузки для локального Kubernetes)
- cert-manager (управление сертификатами)
- Ingress-Nginx (маршрутизация HTTP/HTTPS)
- ClusterIssuers (самоподписанный и для production)
- Echo Server (демо-приложение)

### Шаг 6: Развёртывание

```sh
terraform apply
```

Terraform покажет план и попросит подтверждение. Введите `yes` и нажмите Enter.

Или, чтобы пропустить подтверждение:
```sh
terraform apply -auto-approve
```

Процесс займёт несколько минут. Дождитесь:
```
Apply complete! Resources: XX added, 0 changed, 0 destroyed.
```

### Шаг 7: Проверка развёртывания

Убедитесь, что все поды запущены:
```sh
kubectl get pods -A
```
Все поды в namespace'ах `metallb-system`, `ingress-nginx`, `cert-manager` и `demo` должны быть в статусе `Running`.

Проверьте, что сервисы получили IP-адреса:
```sh
kubectl get svc -A
```
У сервиса `ingress-nginx-controller` должен быть `EXTERNAL-IP` равный `127.0.0.1` (назначенный MetalLB).

Проверьте, что ingress создан:
```sh
kubectl get ingress -A
```

Проверьте, что TLS-сертификат выпущен:
```sh
kubectl get certificates -A
```
В колонке `READY` должно быть значение `True`. Если показывает `False` — подождите минуту, cert-manager может ещё обрабатывать запрос.

Отправьте запрос к echo-серверу:
```sh
curl https://echo.127.0.0.1.nip.io
```
Вы должны получить JSON-ответ. Это подтверждает работу всего стека:
- DNS-резолвинг через nip.io
- MetalLB назначил IP ingress-контроллеру
- Ingress-Nginx маршрутизирует запрос к echo-серверу
- cert-manager выпустил валидный TLS-сертификат
- Echo-сервер запущен и отвечает

Если вы видите ошибку SSL, убедитесь, что выполнили `mkcert -install`. Как обходной путь:
```sh
curl -k https://echo.127.0.0.1.nip.io
```

Также можно открыть https://echo.127.0.0.1.nip.io в браузере.

### Шаг 8: Очистка

Когда закончите эксперименты, выполните следующее из каталога `envs/local`:

**Удалить все ресурсы:**
```sh
terraform destroy
```

**Полный сброс (удалить + удалить состояние + развернуть с нуля):**
```sh
terraform destroy -auto-approve
cd ../..
rm -rf envs/local/.terraform envs/local/terraform.tfstate envs/local/terraform.tfstate.backup
cd envs/local
terraform init -upgrade
terraform apply -auto-approve
```

## Что дальше?

На данный момент у вас есть полностью рабочий Kubernetes-стек на локальной машине:
- **MetalLB** назначает `127.0.0.1` как внешний IP для ingress-контроллера.
- **Ingress-Nginx** маршрутизирует HTTPS-запросы по hostname к нужным backend-сервисам.
- **cert-manager** автоматически выпускает TLS-сертификаты, подписанные вашим локальным CA от mkcert.
- **Echo Server** отвечает по адресу `https://echo.127.0.0.1.nip.io`, доказывая, что вся цепочка работает от начала до конца.

Теперь вы можете строить на этом фундаменте:

- **Добавить свои приложения:** создайте новый Terraform-модуль в `modules/`, следуя паттерну `modules/echo-server` — Deployment, Service и Ingress с аннотацией `cert-manager.io/cluster-issuer`. Terraform сделает остальное.
- **Изменить домен:** поменяйте `root_domain` в `envs/local/locals.tf` (например, на `myapp.local` с настройкой DNS).
- **Поэкспериментировать с Let's Encrypt:** модуль `cluster-issuer-production` уже настроен для реальных ACME-сертификатов. Направьте реальный домен на ваш кластер и переключите имя issuer в Ingress.
- **Визуализировать инфраструктуру:** установите graphviz (`brew install graphviz`) и выполните `terraform graph | dot -Tpng -o graph.png` из каталога `envs/local`.
- **Настроить Git-хуки:** из корня репозитория выполните `cp .hooks/* .git/hooks && chmod -R +x .git/hooks` для автоформатирования при коммите.

## Возможные проблемы

### Terraform запрашивает `cluster_issuer_selfsigned_ca_cert` в интерактивном режиме

Terraform требует две переменные окружения для самоподписанного CA. Если они не заданы, он будет запрашивать их вручную.

**Решение:** экспортируйте переменные перед запуском любой команды Terraform:
```sh
export TF_VAR_cluster_issuer_selfsigned_ca_cert="$(base64 < "$(mkcert -CAROOT)/rootCA.pem")"
export TF_VAR_cluster_issuer_selfsigned_ca_key="$(base64 < "$(mkcert -CAROOT)/rootCA-key.pem")"
```

### Сертификат не доверен / `curl` возвращает ошибку SSL

При запросе `curl https://echo.127.0.0.1.nip.io` может появиться:
```
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

**Причина:** корневой CA от mkcert не установлен в системное хранилище доверенных сертификатов.

**Решение:**
```sh
mkcert -install
```
Это добавит CA от mkcert в системное хранилище. После этого `curl` и браузеры будут доверять сертификату. Как быстрый обходной путь, используйте `curl -k` для пропуска проверки.

### Kubernetes не запущен / `kubectl` не может подключиться

```
The connection to the server localhost:6443 was refused
```

**Решение:** убедитесь, что Docker Desktop запущен и Kubernetes включён в настройках Docker Desktop (Settings > Kubernetes > Enable Kubernetes).

### Ingress-контроллер не получает EXTERNAL-IP (показывает `<pending>`)

```sh
kubectl get svc -n ingress-nginx
# EXTERNAL-IP показывает <pending>
```

**Причина:** MetalLB не готов или пул IP-адресов не настроен.

**Решение:**
1. Проверьте, что поды MetalLB запущены: `kubectl get pods -n metallb-system`
2. Проверьте ресурс IPAddressPool: `kubectl get ipaddresspool -n metallb-system`
3. Попробуйте переразвернуть: `make tf-recreate`

### Сертификат не выпущен (READY показывает False)

```sh
kubectl get certificates -A
# READY показывает False
```

**Решение:** проверьте статус запроса сертификата и логи cert-manager:
```sh
kubectl describe certificaterequest -A
kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager
```
Частая причина: поды cert-manager ещё не готовы. Подождите минуту и проверьте снова.

### ClusterIssuer не готов

```sh
kubectl get clusterissuer
# READY показывает False
```

**Причина:** секрет с CA отсутствует или содержит невалидные данные. Обычно это происходит, когда `TF_VAR_cluster_issuer_selfsigned_ca_cert` или `TF_VAR_cluster_issuer_selfsigned_ca_key` были заданы с неправильными значениями (например, двойное base64-кодирование, пустая строка или неверный путь к файлу).

**Диагностика:**
```sh
kubectl describe clusterissuer selfsigned
kubectl get secret selfsigned-ca -n cert-manager -o yaml
```

**Решение:** убедитесь, что переменные содержат одно base64-закодированное значение:
```sh
# Проверьте, что файлы CA от mkcert существуют
ls "$(mkcert -CAROOT)"

# Переэкспортируйте с правильными значениями
export TF_VAR_cluster_issuer_selfsigned_ca_cert="$(base64 < "$(mkcert -CAROOT)/rootCA.pem")"
export TF_VAR_cluster_issuer_selfsigned_ca_key="$(base64 < "$(mkcert -CAROOT)/rootCA-key.pem")"

# Переприменить
make tf-apply-approve
```

### Сертификат выпущен, но браузер показывает "Не защищено"

Сертификат валиден внутри кластера (`kubectl get certificates` показывает `True`), но браузер показывает предупреждение безопасности.

**Причина:** CA, подписавший сертификат, не является доверенным для вашей ОС/браузера. Кластер использует корневой CA от mkcert, который должен быть установлен локально.

**Решение:**
```sh
# Установить CA от mkcert в системное хранилище
mkcert -install

# Проверить, что установлен
mkcert -CAROOT
```
После этого перезапустите браузер. На macOS также можно проверить в Keychain Access — найдите "mkcert" в системном хранилище (System keychain).

### Ошибка сертификата только в определённом namespace

Если сертификат работает в одном namespace, но не в другом — скорее всего, проблема в отсутствующей или неправильной аннотации Ingress.

**Проверьте**, что у вашего Ingress есть правильная аннотация:
```yaml
annotations:
  cert-manager.io/cluster-issuer: selfsigned
```

**Убедитесь**, что сертификат и секрет существуют в нужном namespace:
```sh
kubectl get certificates -n <namespace>
kubectl get secrets -n <namespace> | grep tls
```

### Отдаётся неправильный сертификат / `SSL: no alternative certificate subject name matches`

```
curl: (60) SSL: no alternative certificate subject name matches target host name 'echo.127.0.0.1.nip.io'
```

Сертификат внутри Kubernetes правильный, но `curl` получает другой.

**Причина:** другой Docker-контейнер или сервис занимает порты 80/443 на хосте, перехватывая трафик до того, как он попадает в Kubernetes ingress-контроллер.

**Диагностика:**
```sh
docker ps | grep -E "0.0.0.0:(80|443)"
```

**Решение:** остановите конфликтующий контейнер и перезапустите ingress-контроллер:
```sh
docker stop <имя-контейнера>
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx
```

### `terraform init` завершается с ошибкой провайдеров

**Решение:** убедитесь, что установлен Terraform >= 1.5.0:
```sh
terraform version
```
Затем повторите:
```sh
make tf-init
```

### Поды зависают в `ContainerCreating` или `CrashLoopBackOff`

**Решение:** посмотрите события пода:
```sh
kubectl describe pod <имя-пода> -n <namespace>
kubectl logs <имя-пода> -n <namespace>
```
Частые причины: проблемы с загрузкой образов (проверьте интернет-соединение), превышены лимиты ресурсов в Docker Desktop (увеличьте память/CPU в настройках Docker Desktop).

### Нужен полностью чистый старт

Если ничего не помогает, выполните полный сброс — это уничтожит все ресурсы, удалит состояние и пересоздаст всё с нуля:
```sh
make tf-reset
```

## Справочник команд Makefile

Проект включает Makefile с сокращениями для частых операций. Все команды Terraform работают с окружением `envs/local`.

| Команда | Описание |
|---------|----------|
| `make tf-init` | Инициализация Terraform (`terraform init -upgrade`) |
| `make tf-plan` | Просмотр изменений (`terraform plan`) |
| `make tf-apply` | Применить изменения с подтверждением (`terraform apply`) |
| `make tf-apply-approve` | Применить изменения без подтверждения (`terraform apply -auto-approve`) |
| `make tf-destroy` | Удалить ресурсы с подтверждением (`terraform destroy`) |
| `make tf-destroy-approve` | Удалить ресурсы без подтверждения (`terraform destroy -auto-approve`) |
| `make tf-recreate` | Удалить и развернуть заново |
| `make tf-reset` | Полный сброс: удалить, очистить состояние, инициализировать и развернуть |
| `make tf-test` | Валидация конфигурации (`terraform validate` + `terraform fmt -check`) |
| `make tf-graph` | Сгенерировать граф инфраструктуры (требуется `graphviz`) |
| `make setup-hooks` | Установить pre-commit хуки для автоформатирования |

---
**Вклад и проблемы**
Если вы столкнулись с проблемами или у вас есть предложения по улучшению — не стесняйтесь вносить свой вклад или создавать issue!

