function start (song)
showOnlyStrums = true
strumLine1Visible = false
strumLine2Visible = false

end

function update (elapsed)
	if curStep == 572 then
		showOnlyStrums = false
		strumLine1Visible = true
		strumLine2Visible = true
	end


	if curStep == 752 or curStep == 758 or curStep == 764 or curStep == 816 or curStep == 822 or curStep == 828 or curStep == 880 or curStep == 886 or curStep == 892 or curStep == 944 or curStep == 950 or curStep == 956 or curStep == 1008 or curStep == 1014 or curStep == 1020 or curStep == 1072 or curStep == 1078 or curStep == 1084 or curStep == 1136 or curStep == 1142 or curStep == 1148 or curStep == 1200 or curStep == 1206 or curStep == 1212 then
		setCamZoom(0.41)
		setHudZoom(1.04)
	end

	if curStep == 1520 or curStep == 1526 or curStep == 1532 or curStep == 1584 or curStep == 1590 or curStep == 1596 or curStep == 1648 or curStep == 1654 or curStep == 1660 or curStep == 1712 or curStep == 1718 or curStep == 1724 or curStep == 1776 or curStep == 1782 or curStep == 1788 or curStep == 1840 or curStep == 1846 or curStep == 1852 or curStep == 1904 or curStep == 1910 or curStep == 1916 or curStep == 1968 or curStep == 1974 or curStep == 1980 or curStep == 1984 then
		setCamZoom(0.42)
		setHudZoom(1.05)
	end

	if curStep == 2288 or curStep == 2294 or curStep == 2300 or curStep == 2352 or curStep == 2358 or curStep == 2364 or curStep == 2416 or curStep == 2422 or curStep == 2428 or curStep == 2480 or curStep == 2486 or curStep == 2492 or curStep == 2544 or curStep == 2550 or curStep == 2556 or curStep == 2608 or curStep == 2614 or curStep == 2620 or curStep == 2672 or curStep == 2678 or curStep == 2684 or curStep == 2736 or curStep == 2742 or curStep == 2748 or curStep == 2752 then
		setCamZoom(0.41)
		setHudZoom(1.04)
	end

	if curStep == 2928 or curStep == 2934 or curStep == 2940 or curStep == 2992 or curStep == 2998 or curStep == 3004 or curStep == 3056 or curStep == 3062 or curStep == 3068 or curStep == 3120 or curStep == 3126 or curStep == 3132 or curStep == 3184 or curStep == 3190 or curStep == 3196 or curStep == 3248 or curStep == 3254 or curStep == 3260 or curStep == 3312 or curStep == 3318 or curStep == 3324 or curStep == 3376 or curStep == 3382 or curStep == 3388 or curStep == 3392 or curStep == 3520 then
		setCamZoom(0.42)
		setHudZoom(1.05)
	end
	end


function beatHit(beat)
	if curStep >= 702 and curStep < 750 or curStep >= 766 and curStep < 814 or curStep >= 834 and curStep < 878 or curStep >= 894 and curStep < 942 or curStep >= 958 and curStep < 1006 or curStep >= 1022 and curStep < 1070 or curStep >= 1090 and curStep < 1134 or curStep >= 1150 and curStep < 1198 then
	setCamZoom(0.4)
	setHudZoom(1.02)
		end

	if curStep >= 1470 and curStep < 1518 or curStep >= 1534 and curStep < 1582 or curStep >= 1598 and curStep < 1646 or curStep >= 1662 and curStep < 1710 or curStep >= 1726 and curStep < 1774 or curStep >= 1790 and curStep < 1838 or curStep >= 1854 and curStep < 1902 or curStep >= 1918 and curStep < 1966 then
	setCamZoom(0.41)
	setHudZoom(1.025)
		end

	if curStep >= 2238 and curStep < 2286 or curStep >= 2302 and curStep < 2350 or curStep >= 2370 and curStep < 2414 or curStep >= 2430 and curStep < 2478 or curStep >= 2494 and curStep < 2542 or curStep >= 2558 and curStep < 2606 or curStep >= 2626 and curStep < 2670 or curStep >= 2686 and curStep < 2734 then
	setCamZoom(0.4)
	setHudZoom(1.02)
		end

	if curStep >= 2878 and curStep < 2926 or curStep >= 2942 and curStep < 2990 or curStep >= 3006 and curStep < 3054 or curStep >= 3070 and curStep < 3118 or curStep >= 3134 and curStep < 3182 or curStep >= 3198 and curStep < 3246 or curStep >= 3262 and curStep < 3310 or curStep >= 3326 and curStep < 3390 then
	setCamZoom(0.41)
	setHudZoom(1.025)
		end
		end