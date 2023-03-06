#include <Windows.h>
#include <iostream>

int main()
{
    // Define variables
    HKEY hKey; // Handle to the registry key
    const char* subKey = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion"; // Subkey to open
    const char* valueName = "ProductName"; // Value name to retrieve
    char buffer[1024]; // Buffer to store the retrieved value
    DWORD bufferSize = sizeof(buffer); // Size of the buffer

    // Open the registry key
    if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, subKey, 0, KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS)
    {
        // Query the value
        if (RegQueryValueExA(hKey, valueName, NULL, NULL, (LPBYTE)buffer, &bufferSize) == ERROR_SUCCESS)
        {
            // Print the retrieved value
            std::cout << "Value: " << buffer << std::endl;
        }
        
        // Close the key
        RegCloseKey(hKey);
    }

    return 0;
}
