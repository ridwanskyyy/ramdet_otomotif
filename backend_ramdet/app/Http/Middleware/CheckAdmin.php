<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        // Memastikan user sudah login dan kolom role bernilai admin
        if ($request->user() && $request->user()->role === 'admin') {
            return $next($request);
        }

        // Response jika user terbukti bukan admin
        return response()->json([
            'success' => false,
            'message' => 'Akses ditolak! Menu ini hanya dapat diakses oleh Admin.'
        ], 403);
    }
}