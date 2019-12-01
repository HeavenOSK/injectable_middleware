import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

/// A callback for [_TypedInjectableMiddleware].
typedef InjectableMiddlewareCallback<State, Action, O> = void Function(
  O dependency,
  Store<State> store,
  Action action,
  NextDispatcher next,
);

/// A type matching middleware which is able to be injected dependency..
class _TypedInjectableMiddleware<State, Action, O>
    implements MiddlewareClass<State> {
  const _TypedInjectableMiddleware({
    @required this.dependency,
    @required this.callback,
  })  : assert(dependency != null),
        assert(callback != null);

  /// Any dependency.
  final O dependency;

  /// A callback for middleware with dependency.
  final InjectableMiddlewareCallback<State, Action, O> callback;

  /// Executes [callback] if tha type of [action] is matched.
  @override
  void call(Store<State> store, dynamic action, NextDispatcher next) {
    if (action is Action) {
      callback(dependency, store, action, next);
    } else {
      next(action);
    }
  }
}

/// A builder for [InjectableMiddleware].
abstract class InjectableMiddlewareBuilder<State, Action, O> {
  const InjectableMiddlewareBuilder({
    @required this.callback,
  }) : assert(callback != null);

  /// A callback for [_TypedInjectableMiddleware].
  @protected
  final InjectableMiddlewareCallback<State, Action, O> callback;

  /// Builds middleware with [dependency].
  @mustCallSuper
  _TypedInjectableMiddleware<State, Action, O> build(O dependency) {
    return _TypedInjectableMiddleware(
      dependency: dependency,
      callback: callback,
    );
  }
}

/// A middleware which is able to be injected dependency.
class InjectableMiddleware<State, O> {
  const InjectableMiddleware({
    @required this.builders,
  }) : assert(builders != null);

  /// A collection of [InjectableMiddlewareBuilder]s.
  final Iterable<InjectableMiddlewareBuilder<State, dynamic, O>> builders;

  /// Generates middleware with a [dependency]..
  Iterable<Middleware<State>> call(O dependency) {
    assert(dependency != null);
    return [
      ...builders.map(
        (builder) => builder.build(dependency),
      ),
    ];
  }
}
