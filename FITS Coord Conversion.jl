using FITSIO
using WCS

function FITS_pix_to_wcs(path, pix_x, pix_y)
    #path = "/mnt/hgfs/Ubuntu-MPhys-Shared/data_ftp/nustar/data/obs/00/8/80001020002/event_cl/nu80001020002A01_cl.evt.gz"
    file = FITS(path)

    header_image = read_header(file[2])
    header_keys  = keys(header_image)

    # Keys used during WCS transform:
    # cdelt -> [TCDLT'X' TCDLT'Y']
    # ctype -> [TCTYP'X' TCTYP'Y']
    # crpix -> [TCRPX'X' TCRPX'Y']
    # crval -> [TCRVL'X' TCRVL'Y']
    # pv    -> coordinates being converted...?

    keys_useful = []

    # To select the useful key types
    # for ALL COORDINATES (DET1, DET2, etc... and desired declination/right ascension)
    for key in header_keys
        if length(key) >= 5
            if key[1:5] in ["TCDLT" "TCTYP" "TCRPX" "TCRVL" "TCNULL"]
                append!(keys_useful, [key])
            end
        end
    end

    # Now that ALL keys have been found, select the ones corresponding to dec/ra
    # to find the key numbers
    keys_radec = []
    for key in keys_useful
        if header_image[key] == "DEC--TAN"
            append!(keys_radec, [key])
        elseif header_image[key] == "RA---TAN"
            append!(keys_radec, [key])
        end
    end

    @assert length(keys_radec) == 2 "Incorrect number of keys found"

    # Keys ending in these numbers correspond to the desired degree units
    keys_radec_id = replace.(keys_radec, "TCTYP", "")

    # In the next part we assume that the key id has TWO DIGITS, which seems to always be true
    # check here anyway
    @assert !(false in [parse.(Int, keys_radec_id) .>= 10]) "Key ID under two digits"

    keys_selected = []
    for key in keys_useful
        if key[end-1:end] in keys_radec_id # Select just keys ending in the key nunber
            append!(keys_selected, [key])
        end
    end

    # Set up the transform
    cdelt = [header_image[string("TCDLT", keys_radec_id[1])], header_image[string("TCDLT", keys_radec_id[2])]]
    ctype = [header_image[string("TCTYP", keys_radec_id[1])], header_image[string("TCTYP", keys_radec_id[2])]]
    crpix = [header_image[string("TCRPX", keys_radec_id[1])], header_image[string("TCRPX", keys_radec_id[2])]]
    crval = [header_image[string("TCRVL", keys_radec_id[1])], header_image[string("TCRVL", keys_radec_id[2])]]

    wcs = WCSTransform(2;
                        cdelt = cdelt,
                        ctype = ctype,
                        crpix = crpix,
                        crval = crval)

    # *1.0 to convert to float
    pixcoords = [pix_x*1.0;  # x coordinates
                 pix_y*1.0]  # y coordinates

    # DS9 only saves coordinates to EIGHT significan figures in .reg files
    # stick to that for consistency

    signif.(pix_to_world(wcs, pixcoords), 8)
end

test_path = path = "/mnt/hgfs/Ubuntu-MPhys-Shared/data_ftp/nustar/data/obs/00/8/80001020002/event_cl/nu80001020002A01_cl.evt.gz"
#500, 500 == 0:06:19.609, +20:12:01.87 == 1.5817028, 20.202568
@assert [true; true] == isapprox.(FITS_pix_to_wcs(test_path, 500, 500), [1.5817028; 20.202568]; rtol=5)


"""
Converts degrees to sexagesimal

WARNING: Converting NuSTAR FITS α to Sexagesimal doesn't seem to give the correct
result, as it differs from what is given by DS9
"""
function decdeg_to_sxgm(deg)
    sign_flag = deg >= 0
    deg = abs(deg)

    mnt, sec = divrem(deg*3600, 60)
    deg, mnt = divrem(mnt,      60)

    if !sign_flag # If degrees are negative
        deg = -deg
    end

    return deg, mnt, sec
end

@assert decdeg_to_sxgm(-(40 + (30/60) + (1/3600))) == (-40.0, 30.0, 1.0)

@assert decdeg_to_sxgm(40 + (30/60) + (1/3600)) == (40.0, 30.0, 1.0)
