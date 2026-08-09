from pysolarmanv5 import PySolarmanV5

def main():
    # Target Configuration
    modbus_host = "REDACTED_INTERNAL_IP"
    logger_sn = 519499628
    
    # Initialize connection to Slave ID 1 (Responsive ID from previous scan)
    # Using Port 8899 as identified in nmap report
    solarman = PySolarmanV5(modbus_host, logger_sn, port=8899, mb_slave_id=1, verbose=False)

    print(f"[*] Connecting to Solis Inverter at {modbus_host}...")

    try:
        # Step 1: Read Live Data (Input Registers - Function 04)
        # 33000 is the standard start address for Solis live metrics
        input_data = solarman.read_input_registers(register_addr=33000, quantity=80)
        
        print("\n[+] SUCCESS: LIVE DATA RETRIEVED")
        print(f"----------------------------------------")
        
        # Mapping for Solis Inverters
        # Power (W) is at offset 35
        current_power = input_data[35]
        # DC Voltage (V) at offset 22 (scaled by 0.1)
        dc_voltage = input_data[22] * 0.1
        # Today's Yield (kWh) at offset 34 (scaled by 0.1)
        today_yield = input_data[34] * 0.1
        # Total Yield (kWh) is a 32-bit value (Registers 8 and 9)
        total_yield = ((input_data[9] << 16) + input_data[8]) * 0.1

        print(f"Current Power:    {current_power} W")
        print(f"DC Bus Voltage:   {dc_voltage} V")
        print(f"Today's Energy:   {today_yield} kWh")
        print(f"Total Lifetime:   {total_yield:.1f} kWh")
        print(f"----------------------------------------")

    except Exception as e:
        print(f"[-] Failed to read Input Registers (33000). Error: {e}")
        
    try:
        # Step 2: Read System Settings (Holding Registers - Function 03)
        # 3000 is the standard start for holding/control registers
        holding_data = solarman.read_holding_registers(register_addr=3000, quantity=20)
        
        print("\n[+] SUCCESS: SYSTEM SETTINGS RETRIEVED")
        print(f"----------------------------------------")
        # Example: Inverter Date/Time (Registers 3010-3012)
        print(f"Inverter Date: 20{holding_data[10]}-{holding_data[11]}-{holding_data[12]}")
        print(f"----------------------------------------")

    except Exception as e:
        print(f"[-] Failed to read Holding Registers (3000). Error: {e}")

if __name__ == "__main__":
    main()