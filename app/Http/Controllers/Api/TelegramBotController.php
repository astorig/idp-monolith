<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

class TelegramBotController extends Controller
{
    /**
     * @return JsonResponse
     */
    public function auth(): JsonResponse
    {
        return response()->json([
           'status' => true,
            'hello' => ['hola!']
        ]);
    }
}
