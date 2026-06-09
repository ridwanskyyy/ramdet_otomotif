<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Auth\AuthenticationException; 
use Illuminate\Http\Request; 

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
    })
   ->withExceptions(function (Exceptions $exceptions): void {
        
        // Handle error jika belum login
        $exceptions->render(function (AuthenticationException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal memproses! Anda harus login terlebih dahulu.',
                    'data' => null
                ], 401);
            }
        });

        // BARU: Handle global jika data produk atau data apapun tidak ditemukan (404) di API
        $exceptions->render(function (\Symfony\Component\HttpKernel\Exception\NotFoundHttpException $e, Request $request) {
            if ($request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal memproses! Data tidak tersedia atau sudah dihapus.'
                ], 404);
            }
        });

    })->create();