# Include the library makefile
include $(addprefix ./vendor/github.com/openshift/build-machinery-go/make/, \
	golang.mk \
)

# Build configuration
git_commit=$(shell git describe --tags --always --dirty)
build_date=$(shell date -u '+%Y%m%d')
version=v${build_date}-${git_commit}

SOURCE_GIT_TAG=v1.0.0+$(shell git rev-parse --short=7 HEAD)

GO_LD_EXTRAFLAGS=-X github.com/openshift/ci-chat-bot/vendor/k8s.io/client-go/pkg/version.gitCommit=$(shell git rev-parse HEAD) -X github.com/openshift/ci-chat-bot/vendor/k8s.io/client-go/pkg/version.gitVersion=${SOURCE_GIT_TAG} -X k8s.io/test-infra/prow/version.Name=ci-chat-bot -X k8s.io/test-infra/prow/version.Version=${version}
GOLINT=golangci-lint run

debug:
	go build -gcflags="all=-N -l" ${GO_LD_FLAGS} -mod vendor -o ci-chat-bot ./cmd/...
.PHONY: debug

vendor:
	go mod tidy
	go mod vendor
.PHONY: vendor

validate-vendor: vendor
	git status -s ./vendor/ go.mod go.sum
	test -z "$$(git status -s ./vendor/ go.mod go.sum | grep -v vendor/modules.txt)"
.PHONY: validate-vendor

run:
	./hack/run.sh
.PHONY: run

lint: verify-golint
