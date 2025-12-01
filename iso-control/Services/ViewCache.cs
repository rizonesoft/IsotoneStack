using System;
using System.Collections.Generic;

namespace Isotone.Services
{
    public class ViewCache
    {
        private readonly Dictionary<string, object> _cache = new Dictionary<string, object>();
        private readonly Dictionary<string, Func<object>> _factories = new Dictionary<string, Func<object>>();

        public void RegisterFactory(string key, Func<object> factory)
        {
            _factories[key] = factory;
        }

        public object GetOrCreate(string key)
        {
            if (_cache.TryGetValue(key, out var cached))
            {
                return cached;
            }

            if (_factories.TryGetValue(key, out var factory))
            {
                var view = factory();
                _cache[key] = view;
                return view;
            }

            throw new InvalidOperationException($"No factory registered for key: {key}");
        }

        public void Clear()
        {
            _cache.Clear();
        }

        public void Remove(string key)
        {
            _cache.Remove(key);
        }
    }
}