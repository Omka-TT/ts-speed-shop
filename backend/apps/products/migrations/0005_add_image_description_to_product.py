from django.db import migrations, models


def set_image_and_description(apps, schema_editor):
    Product = apps.get_model('products', 'Product')
    items = {
        4: {
            'image_url': 'assets/images/capcut-logo.jpg',
            'description': 'CapCut: fast, mobile-first video editing with professional-style results.',
        },
        5: {
            'image_url': 'assets/images/Adobe_Photoshop_Lightroom_logo.png',
            'description': 'Adobe Lightroom: advanced photo editing, organization, and cloud sync.',
        },
        6: {
            'image_url': 'assets/images/Picsart_logo.png',
            'description': 'Picsart: creative photo editor, collage maker, and drawing tool.',
        },
        7: {
            'image_url': 'assets/images/InShot_logo.png',
            'description': 'InShot: quick video trimming, filters, and social-ready formatting.',
        },
        8: {
            'image_url': 'assets/images/Canva-logo.png',
            'description': 'Canva: intuitive design suite for social media posts and visual branding.',
        },
        9: {
            'image_url': 'assets/images/Snapseed_logo.png',
            'description': 'Snapseed: precision photo retouching from Google with pro filters.',
        },
        10: {
            'image_url': 'assets/images/VSCO_logo.png',
            'description': 'VSCO: minimalistic photo editing with premium film-like presets.',
        },
        11: {
            'image_url': 'assets/images/Adobe_Premiere_Pro_logo.png',
            'description': 'Adobe Premiere Pro: industry-standard video editing for professionals.',
        },
        12: {
            'image_url': 'assets/images/DaVinci_Resolve_logo.png',
            'description': 'DaVinci Resolve: color-grade and edit in one high-powered suite.',
        },
        13: {
            'image_url': 'assets/images/KineMaster_logo1.webp',
            'description': 'KineMaster: full-featured mobile video editor with multilayer support.',
        },
        14: {
            'image_url': 'assets/images/w-video_logo.jpg',
            'description': 'Adobe Premiere Pro (alternate listing): editing workflow with creative cloud integration.',
        },
        15: {
            'image_url': 'assets/images/Final_Cut_Pro_logo.png',
            'description': 'DaVinci Resolve (alternate listing): collaborative post-production and fusion VFX.',
        },
        16: {
            'image_url': 'assets/images/Final_Cut_Pro_logo.png',
            'description': 'Final Cut Pro: Apple video editor for fast, magnetic timeline production.',
        },
        17: {
            'image_url': 'assets/images/LumaFusion_logo.jpg',
            'description': 'LumaFusion: pro mobile video editing app with multi-track timeline.',
        },
        18: {
            'image_url': 'assets/images/filmora_logo.png',
            'description': 'CapCut (alternate listing): easy-to-use interface for quick content creation.',
        },
        19: {
            'image_url': 'assets/images/Adobe_Photoshop_logo.png',
            'description': 'Adobe Photoshop: powerful image composition and raster design tools.',
        },
        20: {
            'image_url': 'assets/images/Capture_One_logo.png',
            'description': 'Adobe Lightroom (alternate listing): photo enhancements for hobbyists and pros.',
        },
        21: {
            'image_url': 'assets/images/Capture_One_logo.png',
            'description': 'Capture One: advanced raw processing for professional photographers.',
        },
        22: {
            'image_url': 'assets/images/Affinity_Photo_logo.png',
            'description': 'Affinity Photo: one-time-payment photo editing with industry-grade tools.',
        },
        23: {
            'image_url': 'assets/images/blurrr_logo.png',
            'description': 'Snapseed (alternate listing): superset of quick edits and finishers for social media.',
        },
    }

    for product_id, values in items.items():
        try:
            product = Product.objects.get(id=product_id)
            product.image_url = values['image_url']
            product.description = values['description']
            product.save(update_fields=['image_url', 'description'])
        except Product.DoesNotExist:
            # skip if record missing
            continue


def unset_image_and_description(apps, schema_editor):
    Product = apps.get_model('products', 'Product')
    Product.objects.filter(id__gte=4, id__lte=23).update(image_url='', description='')


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0004_product_type'),
    ]

    operations = [
        migrations.AddField(
            model_name='product',
            name='description',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='product',
            name='image_url',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
        migrations.RunPython(set_image_and_description, unset_image_and_description),
    ]
