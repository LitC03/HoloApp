// Include IDS peak
#include <peak/peak.hpp>
 
int main()
{
  // Initialize library
  peak::Library::Initialize();
 
  // Create a DeviceManager object
  auto& deviceManager = peak::DeviceManager::Instance();
 
  try
  {
      // Update the DeviceManager
      deviceManager.Update();
 
      // Exit program if no device was found
      if (deviceManager.Devices().empty())
      {
          std::cout << "No device found. Exiting program." << std::endl << std::endl;
          peak::Library::Close();
          return -1;
      }
 
      // Open the first device
      auto device = deviceManager.Devices().at(0)->OpenDevice(peak::core::DeviceAccessType::Control);
 
      // ... Do something with the device here
 
  }
  catch (const std::exception& e)
  {
      std::cout << "EXCEPTION: " << e.what() << std::endl;
      peak::Library::Close();
      return -2;
  }
 
  // Close library
  peak::Library::Close();
  return 0;
}