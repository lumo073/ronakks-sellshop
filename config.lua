Config = {}

-- Configuration for peds
Config.Peds = {
    [1] = {
        model = "cs_floyd", 
        scenario = "WORLD_HUMAN_CLIPBOARD", 
        coords = vector4(25.56, -1349.72, 29.33, 178.23), -- Change Z-coordinate as needed
        shopName = "Selling Foods",  -- Individual shop name
        items = {
            [1] = {
                label = "Water Bottle", -- Display name of the item
                model = "water_bottle", -- Item model (not prop)
                description = "Slightly old disgust water", -- Short description
                price = 250 -- Price of the item
            },
            [2] = {
                label = "Sandwich", -- Display name of the item
                model = "sandwich", -- Item model (not prop)
                description = "A little smellful bread", -- Short description
                price = 150 -- Price of the item
            }
            -- Add more peds and items as needed with their respective shop names
        }
    },
   -- Note: Adjust Z-coordinates of peds in `Config.Peds` as needed to align with the ground coordinates.
-- Use `vector4(X, Y, Z, heading)` where `Z` might need to be decreased to ensure peds are ground-aligned.
}
