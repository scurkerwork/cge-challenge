<?php

namespace App\Repository;
use App\Models\User;

class UserRepository
{
    public function getUsers() {
        $users = User::all();
        return $users;
    }

    

}
