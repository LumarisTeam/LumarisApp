enum FetchPolicy { localFirst, refresh, fallbackToLocal }

class FetchSnapshot<T> {
  const FetchSnapshot({
    required this.data,
    required this.isFromLocal,
    required this.isStale,
  });

  final T data;
  final bool isFromLocal;
  final bool isStale;
}
