<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class PaymentCalculator extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {

        $workspaces = Workspace::all();
        
        return view('payment_calculator');
    }
}
