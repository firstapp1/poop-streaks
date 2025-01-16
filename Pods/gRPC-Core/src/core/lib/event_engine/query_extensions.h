// Copyright 2023 gRPC Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
#ifndef GRPC_SRC_CORE_LIB_EVENT_ENGINE_QUERY_EXTENSIONS_H
#define GRPC_SRC_CORE_LIB_EVENT_ENGINE_QUERY_EXTENSIONS_H

#include "absl/strings/string_view.h"

#include <grpc/event_engine/event_engine.h>
#include <grpc/support/port_platform.h>

namespace grpc_event_engine {
namespace experimental {

namespace endpoint_detail {

template <typename Querying, typename... Es>
struct QueryExtensionRecursion;

template <typename Querying, typename E, typename... Es>
struct QueryExtensionRecursion<Querying, E, Es...> {
  static void* Query(absl::string_view id, Querying* p) {
    if (id == E::EndpointExtensionName()) return static_cast<E*>(p);
    return QueryExtensionRecursion<Querying, Es...>::Query(id, p);
  }
};

template <typename Querying>
struct QueryExtensionRecursion<Querying> {
  static void* Query(absl::string_view, Querying*) { return nullptr; }
};

}  // namespace endpoint_detail

// A helper class to derive from some set of base classes and export
// QueryExtension for them all.
// EventEngine Extensible object implementations which need to support different
// extensions just need to derive from this class.
template <typename EEClass, typename... Exports>
class ExtendedType : public EEClass, public Exports... {
 public:
  void* QueryExtension(absl::string_view id) override {
    return endpoint_detail::QueryExtensionRecursion<ExtendedType,
                                                    Exports...>::Query(id,
                                                                       this);
  }
};

/// A helper method which returns a valid pointer if the extension is
/// supported by the endpoint.
template <typename T>
T* QueryExtension(EventEngine::Endpoint* endpoint) {
  if (endpoint == nullptr) return nullptr;
  return static_cast<T*>(endpoint->QueryExtension(T::EndpointExtensionName()));
}

/// A helper method which returns a valid pointer if the extension is
/// supported by the listener.
template <typename T>
T* QueryExtension(EventEngine::Listener* listener) {
  if (listener == nullptr) return nullptr;
  return static_cast<T*>(listener->QueryExtension(T::EndpointExtensionName()));
}

/// A helper method which returns a valid pointer if the extension is
/// supported by the EventEngine.
template <typename T>
T* QueryExtension(EventEngine* engine) {
  if (engine == nullptr) return nullptr;
  return static_cast<T*>(engine->QueryExtension(T::EndpointExtensionName()));
}

}  // namespace experimental
}  // namespace grpc_event_engine

#endif  // GRPC_SRC_CORE_LIB_EVENT_ENGINE_QUERY_EXTENSIONS_H
