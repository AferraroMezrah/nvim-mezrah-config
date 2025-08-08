-- lua/work/config/filetypes.lua

-- Add custom filetypes for Salesforce
vim.filetype.add({
  extension = {
    -- Apex classes and triggers
    cls = "apex",
    trigger = "apex",
    apex = "apex",

    -- Visualforce pages (can map to html for now)
    page = "html",  -- or "visualforce" if you define a custom type later
    component = "html",  -- or "visualforce" if you define a custom type later
  },

  -- Optional: you could map filenames or patterns here if needed later
  filename = {
    -- Add static file name mappings if needed
    -- ["MyApexFile.cls"] = "apex",
  },

  pattern = {
    -- e.g., match based on path if needed
    -- [".*/somepath/.*%.page"] = "visualforce",
  },
})
