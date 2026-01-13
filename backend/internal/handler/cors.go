package handler

import "net/http"

// CORSMiddleware adds CORS headers for frontend access
func CORSMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Allow any origin in development
		origin := r.Header.Get("Origin")
		if origin == "" {
			origin = "*"
		}

		w.Header().Set("Access-Control-Allow-Origin", origin)
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers",
			"Authorization, Content-Type, Content-Length, Upload-Offset, Upload-Length, "+
				"Upload-Metadata, Upload-Defer-Length, Upload-Concat, Tus-Resumable, Tus-Version, "+
				"Tus-Extension, Tus-Max-Size, X-HTTP-Method-Override, X-Requested-With")
		w.Header().Set("Access-Control-Expose-Headers",
			"Upload-Offset, Upload-Length, Location, Tus-Version, Tus-Resumable, "+
				"Tus-Extension, Tus-Max-Size, Upload-Metadata, Content-Disposition")
		w.Header().Set("Access-Control-Max-Age", "86400")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Handle preflight
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}
