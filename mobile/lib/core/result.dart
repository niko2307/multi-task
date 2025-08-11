sealed class Result<T> {
  const Result();
  R match<R>({required R Function(T) ok, required R Function(Object) err});
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
  @override
  R match<R>({required R Function(T) ok, required R Function(Object) err}) =>
      ok(value);
}

class Err<T> extends Result<T> {
  final Object error;
  const Err(this.error);
  @override
  R match<R>({required R Function(T) ok, required R Function(Object) err}) =>
      err(error);
}
