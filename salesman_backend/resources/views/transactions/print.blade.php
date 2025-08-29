<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cetak Transaksi #{{ $transaction->code }}</title>
    <style>
        @page { margin: 0; }
        body {
            font-family: 'Arial', sans-serif;
            font-size: 12px;
            line-height: 1.4;
            margin: 20px;
        }
        .header {
            text-align: center;
            margin-bottom: 20px;
            border-bottom: 1px solid #eee;
            padding-bottom: 10px;
        }
        .header h1 {
            margin: 0;
            font-size: 18px;
        }
        .info {
            margin-bottom: 20px;
        }
        .info p {
            margin: 3px 0;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 5px;
            text-align: left;
        }
        th {
            background-color: #f5f5f5;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .total {
            margin-top: 20px;
            text-align: right;
            font-weight: bold;
        }
        .footer {
            margin-top: 40px;
            text-align: center;
            font-size: 11px;
            color: #666;
        }
        @media print {
            .no-print {
                display: none;
            }
            body {
                margin: 0;
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>NOTA TRANSAKSI</h1>
        <p>No: {{ $transaction->code }}</p>
    </div>

    <div class="info">
        <p><strong>Toko:</strong> {{ $transaction->consignment->store->name ?? '-' }}</p>
        <p><strong>Alamat:</strong> {{ $transaction->consignment->store->address ?? '-' }}</p>
        <p><strong>Tanggal:</strong> {{ $transaction->transaction_date->format('d/m/Y H:i') }}</p>
        <p><strong>Konsinyasi:</strong> {{ $transaction->consignment->code ?? '-' }}</p>
        <p><strong>Sales:</strong> {{ $transaction->consignment->salesman->name ?? '-' }}</p>
    </div>

    <table>
        <thead>
            <tr>
                <th>No</th>
                <th>Kode</th>
                <th>Nama Barang</th>
                <th class="text-right">Harga</th>
                <th class="text-center">Terjual</th>
                <th class="text-center">Kembali</th>
                <th class="text-right">Subtotal</th>
            </tr>
        </thead>
        <tbody>
            @foreach($transaction->items as $index => $item)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $item->code }}</td>
                <td>{{ $item->name }}</td>
                <td class="text-right">{{ number_format($item->price, 0, ',', '.') }}</td>
                <td class="text-center">{{ $item->sales }}</td>
                <td class="text-center">{{ $item->return }}</td>
                <td class="text-right">{{ number_format(($item->sales - $item->return) * $item->price, 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="total">
        <p>Total: Rp {{ number_format($transaction->total_amount, 0, ',', '.') }}</p>
    </div>

    <div class="footer">
        <p>Dicetak pada: {{ now()->format('d/m/Y H:i') }}</p>
        <p>Hak Cipta &copy; {{ date('Y') }} - {{ config('app.name') }}</p>
    </div>

    <div class="no-print" style="margin-top: 20px; text-align: center;">
        <button onclick="window.print()" style="padding: 8px 16px; background: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer;">
            Cetak Halaman Ini
        </button>
        <button onclick="window.close()" style="padding: 8px 16px; margin-left: 10px; background: #f44336; color: white; border: none; border-radius: 4px; cursor: pointer;">
            Tutup
        </button>
    </div>

    <script>
        window.onload = function() {
            // Auto-print when page loads (optional)
            // window.print();
        };
    </script>
</body>
</html>
