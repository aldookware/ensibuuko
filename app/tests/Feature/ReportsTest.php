<?php

namespace Tests\Feature;

use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ReportsTest extends TestCase
{
    /**
     * A basic test example.
     *
     * @return void
     */

    public function test_reports_transactions_api_returns_data(){
        $response = $this->json('GET', '/api/reports/transactions');
        $response->assertStatus(200);
    }
}
