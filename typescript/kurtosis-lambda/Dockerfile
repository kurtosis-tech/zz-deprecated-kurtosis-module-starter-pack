# kevins-image
FROM scratch

WORKDIR /build

COPY ~/kevins-file.txt .







# node-alpine
FROM alpine

RUN ...something to install npm....

RUN npm install yarn




# generate-protoc-bindings Docker image
FROM protoc

RUN ...install ts-protoc-gen....

RUN ...install go-protoc-gen....

MOUNT . /source-files

CMD protoc --js_out=/source-files/out


# Testsuite Starter Pack
FROM node:14.17 AS builder

WORKDIR /build

COPY package.json .  # Adds a tgz to unzip with package.json
COPY yarn.lock .     # Same for yarn.lock

RUN yarn install    # Also add a tgz for whatever comes out of this - this will create node_modules/

# Copy the code into the container
COPY . .

RUN yarn build  # Compiles our .ts files, using the already-installed node_modules, and outputs a build/server.js

# Build the application
CMD node build/main.js

# ============= Execution Stage ================
FROM node:14.17-alpine AS execution

WORKDIR /run

ENV NODE_ENV production

# Copy the code into the container
COPY --from=builder /build/build

# Copy local static files inside the testsuite image
COPY testsuite/static_files /static-files

CMD ./testsuite.bin

