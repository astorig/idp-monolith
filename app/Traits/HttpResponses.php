<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;

trait HttpResponses {
    protected function success($data, $code = 200, $message = null): JsonResponse
    {
        return response()->json([
            'status' => 'Request was successful',
            'message' => $message,
            'data' => $data
        ], $code);
    }

    protected function error($data, $code, $message = null): JsonResponse
    {
        return response()->json([
            'status' => 'Error has occurred',
            'message' => $message,
            'data' => $data
        ], $code);
    }
}
