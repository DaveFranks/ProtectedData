Add-Type -TypeDefinition @'
    namespace PowerShellUtils
    {
        using System;
        using System.Runtime.InteropServices;

        public sealed class PinnedArray<T> : IDisposable
        {
            private readonly T[] array;
            private readonly GCHandle gcHandle;
            public readonly bool ClearOnDispose = true;

            private bool isDisposed = false;

            public static implicit operator T[](PinnedArray<T> pinnedArray)
            {
                return pinnedArray.Array;
            }

            public T this[int key]
            {
                get
                {
                    if (isDisposed) { throw new ObjectDisposedException("PinnedArray"); }
                    return array[key];
                }

                set
                {
                    if (isDisposed) { throw new ObjectDisposedException("PinnedArray"); }
                    array[key] = value;
                }
            }

            public T[] Array
            {
                get
                {
                    if (isDisposed) { throw new ObjectDisposedException("PinnedArray"); }
                    return array;
                }
            }

            public int Length
            {
                get
                {
                    if (isDisposed) { throw new ObjectDisposedException("PinnedArray"); }
                    return array.Length;
                }
            }

            public int Count
            {
                get { return Length; }
            }

            public PinnedArray(uint byteCount)
            {
                array = new T[byteCount];
                gcHandle = GCHandle.Alloc(Array, GCHandleType.Pinned);
            }

            public PinnedArray(uint byteCount, bool clearOnDispose) : this(byteCount)
            {
                ClearOnDispose = clearOnDispose;
            }

            public PinnedArray(T[] array)
            {
                if (array == null) { throw new ArgumentNullException("array"); }

                this.array = array;
                gcHandle = GCHandle.Alloc(this.array, GCHandleType.Pinned);
            }

            public PinnedArray(T[] array, bool clearOnDispose) : this(array)
            {
                ClearOnDispose = clearOnDispose;
            }

            ~PinnedArray()
            {
                Dispose();
            }

            public void Dispose()
            {
                if (isDisposed) { return; }

                if (array != null && ClearOnDispose) { System.Array.Clear(array, 0, array.Length); }
                if (gcHandle != null) { gcHandle.Free(); }

                isDisposed = true;
            }
        }
    }
'@
