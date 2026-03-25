from django.db import migrations


def set_unique_images_descriptions(apps, schema_editor):
    Product = apps.get_model('products', 'Product')
    values = {
        4: 'assets/images/capcut-logo.jpg',
        5: 'assets/images/Adobe_Photoshop_Lightroom_logo.png',
        6: 'assets/images/Picsart_logo.png',
        7: 'assets/images/InShot_logo.png',
        8: 'assets/images/Canva-logo.png',
        9: 'assets/images/Snapseed_logo.png',
        10: 'assets/images/VSCO_logo.png',
        11: 'assets/images/Adobe_Premiere_Pro_logo.png',
        12: 'assets/images/DaVinci_Resolve_logo.png',
        13: 'assets/images/KineMaster_logo1.webp',
        14: 'assets/images/w-video_logo.jpg',
        15: 'assets/images/KineMaster_logo.svg',
        16: 'assets/images/Final_Cut_Pro_logo.png',
        17: 'assets/images/LumaFusion_logo.jpg',
        18: 'assets/images/filmora_logo.png',
        19: 'assets/images/Adobe_Photoshop_logo.png',
        20: 'assets/images/Capture_One_logo.png',
        21: 'assets/images/Affinity_Photo_logo.png',
        22: 'assets/images/apple-pay.png',
        23: 'assets/images/google-pay.png',
    }

    descriptions = {
        4: 'CapCut: fast, mobile-first video editing with professional-style results.',
        5: 'Adobe Lightroom: advanced photo editing, organization, and cloud sync.',
        6: 'Picsart: creative photo editor, collage maker, and drawing tool.',
        7: 'InShot: quick video trimming, filters, and social-ready formatting.',
        8: 'Canva: intuitive design suite for social media posts and visual branding.',
        9: 'Snapseed: precision photo retouching from Google with pro filters.',
        10: 'VSCO: minimalistic photo editing with premium film-like presets.',
        11: 'Adobe Premiere Pro: industry-standard video editing for professionals.',
        12: 'DaVinci Resolve: color-grade and edit in one high-powered suite.',
        13: 'KineMaster: full-featured mobile video editor with multilayer support.',
        14: 'Premiere Pro (duplicate ID): professional editing timeline inside a second entry.',
        15: 'KineMaster (duplicate ID): mobile editor with chroma key and audio features.',
        16: 'Final Cut Pro: Apple video editor for fast, magnetic timeline production.',
        17: 'LumaFusion: pro mobile video editing app with multi-track timeline.',
        18: 'Filmora: easy-to-use interface for quick content creation.',
        19: 'Adobe Photoshop: powerful image composition and raster design tools.',
        20: 'Capture One: premier raw processing for studio photographers.',
        21: 'Affinity Photo: one-time-payment photo editing with professional tools.',
        22: 'Apple Pay (dummy gallery item entry): secure one-touch payments.',
        23: 'Google Pay (dummy gallery item entry): fast checkout integration.',
    }

    for product_id, image_path in values.items():
        try:
            product = Product.objects.get(id=product_id)
            product.image_url = image_path
            product.description = descriptions.get(product_id, product.description)
            product.save(update_fields=['image_url', 'description'])
        except Product.DoesNotExist:
            continue


def unset_unique_images_descriptions(apps, schema_editor):
    Product = apps.get_model('products', 'Product')
    Product.objects.filter(id__gte=4, id__lte=23).update(image_url='', description='')


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0005_add_image_description_to_product'),
    ]

    operations = [
        migrations.RunPython(set_unique_images_descriptions, unset_unique_images_descriptions),
    ]
