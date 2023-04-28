<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginUserRequest;
use App\Http\Requests\StoreUserRequest;
use App\Models\User;
use App\Traits\HttpResponses;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    use HttpResponses;

    public function login(LoginUserRequest $request)
    {
        $request->validated($request->all());

        if (!Auth::attempt($request->only('email', 'password'))) {
            return $this->error('', 401, 'Credentials do not match');
        }

        $user = User::where(['email' => $request->email])->first();

        return $this->success([
            'user' => $user,
            'token' => $user->createToken('API Token of ' . $user->name)->toArray()['plainTextToken']
        ]);
    }

    public function register(StoreUserRequest $request)
    {
        $request->validated($request->all());

        $user = User::create([
           'name' => $request->name,
           'email' => $request->email,
           'password' => Hash::make($request->password)
        ]);

        return $this->success([
            'user' => $user,
            'token' => $user->createToken('API Token of ' . $user->name)->toArray()['plainTextToken']
        ]);
    }

    public function logout()
    {
        return 'hello';
    }
}
